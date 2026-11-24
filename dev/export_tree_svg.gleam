//// Standalone diagnostic (audit B4): export the REAL runtime view tree to SVG.
//// Reads plushie.get_tree (what the window actually draws), walks every canvas
//// shape node, applies group/affine transforms, writes artifacts/glibe_runtime_tree.svg,
//// and prints crosshair-shape counts before/after a dispatched pointer Move.
//// Run: gleam run -m export_tree_svg  (60 real Binance bars are fetched).
//// This is the repeatable "is the window actually drawing?" check: unit-green
//// never proved the window had content (R82). It is NOT the app itself.

import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import glibe
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/symbol
import glibe/binance/rest
import glibe/id
import plushie
import plushie/event
import plushie/node.{
  type Node, type PropValue, DictVal, FloatVal, IntVal, ListVal, StringVal,
}

const canvas_w = 800.0

const canvas_h = 400.0

fn pstr(p: Dict(String, PropValue), key: String, default: String) -> String {
  case dict.get(p, key) {
    Ok(StringVal(s)) -> s
    _ -> default
  }
}

fn pfloat(p: Dict(String, PropValue), key: String, default: Float) -> Float {
  case dict.get(p, key) {
    Ok(FloatVal(f)) -> f
    Ok(IntVal(i)) -> int_to_float(i)
    _ -> default
  }
}

fn int_to_float(i: Int) -> Float {
  int.to_float(i)
}

fn fs(f: Float) -> String {
  float.to_string(f)
}

fn find_canvas(node: Node) -> Option(Node) {
  case node.kind {
    "canvas" -> Some(node)
    _ ->
      case list.find(node.children, fn(c) { find_canvas(c) != None }) {
        Ok(child) -> find_canvas(child)
        Error(_) -> None
      }
  }
}

// A transform chain string from a group's "transforms" ListVal.
fn transform_of(props: Dict(String, PropValue)) -> String {
  case dict.get(props, "transforms") {
    Ok(ListVal(ts)) ->
      list.map(ts, fn(t) {
        case t {
          DictVal(d) ->
            case pstr(d, "type", "") {
              "translate" ->
                "translate("
                <> fs(pfloat(d, "x", 0.0))
                <> ","
                <> fs(pfloat(d, "y", 0.0))
                <> ")"
              "scale" ->
                "scale("
                <> fs(pfloat(d, "x", 1.0))
                <> ","
                <> fs(pfloat(d, "y", 1.0))
                <> ")"
              "rotate" -> "rotate(" <> fs(pfloat(d, "angle", 0.0)) <> ")"
              _ -> ""
            }
          _ -> ""
        }
      })
      |> string.join(" ")
    _ -> ""
  }
}

fn stroke_of(props: Dict(String, PropValue)) -> String {
  case dict.get(props, "stroke") {
    Ok(DictVal(d)) ->
      " stroke=\""
      <> pstr(d, "color", "#ffffff")
      <> "\" stroke-width=\""
      <> fs(pfloat(d, "width", 1.0))
      <> "\""
    _ -> ""
  }
}

fn fill_of(props: Dict(String, PropValue)) -> String {
  case dict.get(props, "fill") {
    Ok(StringVal(c)) -> " fill=\"" <> c <> "\""
    _ -> " fill=\"none\""
  }
}

fn shape_to_svg(node: Node, transform: String) -> String {
  let t = case transform {
    "" -> ""
    _ -> " transform=\"" <> transform <> "\""
  }
  case node.kind {
    "rect" ->
      "<rect x=\""
      <> fs(pfloat(node.props, "x", 0.0))
      <> "\" y=\""
      <> fs(pfloat(node.props, "y", 0.0))
      <> "\" width=\""
      <> fs(pfloat(node.props, "w", 0.0))
      <> "\" height=\""
      <> fs(pfloat(node.props, "h", 0.0))
      <> "\""
      <> fill_of(node.props)
      <> stroke_of(node.props)
      <> t
      <> "/>"
    "line" ->
      "<line x1=\""
      <> fs(pfloat(node.props, "x1", 0.0))
      <> "\" y1=\""
      <> fs(pfloat(node.props, "y1", 0.0))
      <> "\" x2=\""
      <> fs(pfloat(node.props, "x2", 0.0))
      <> "\" y2=\""
      <> fs(pfloat(node.props, "y2", 0.0))
      <> "\""
      <> stroke_of(node.props)
      <> t
      <> "/>"
    "text" ->
      "<text x=\""
      <> fs(pfloat(node.props, "x", 0.0))
      <> "\" y=\""
      <> fs(pfloat(node.props, "y", 0.0))
      <> "\" font-size=\""
      <> fs(pfloat(node.props, "size", 10.0))
      <> "\""
      <> fill_of(node.props)
      <> t
      <> ">"
      <> pstr(node.props, "content", "")
      <> "</text>"
    "path" -> "<path" <> stroke_of(node.props) <> t <> "/>"
    "group" -> {
      let child_t = case transform_of(node.props) {
        "" -> t
        g -> t <> " transform=\"" <> g <> "\""
      }
      "<g"
      <> child_t
      <> ">"
      <> string.join(list.map(node.children, fn(c) { shape_to_svg(c, "") }), "")
      <> "</g>"
    }
    _ -> ""
  }
}

fn layer_to_svg(layer: Node) -> String {
  "<g data-layer=\""
  <> pstr(layer.props, "name", layer.id)
  <> "\">"
  <> string.join(list.map(layer.children, fn(n) { shape_to_svg(n, "") }), "")
  <> "</g>"
}

fn count_layer_shapes(node: Node, name: String) -> Int {
  let here = case dict.get(node.props, "name") {
    Ok(StringVal(n)) if n == name -> list.length(node.children)
    _ -> 0
  }
  here
  + list.fold(node.children, 0, fn(acc, c) { acc + count_layer_shapes(c, name) })
}

/// A pointer Move targeted at the scoped chart widget (R82: routing uses the
/// scoped id), to prove a real dispatched event reaches the widget handler.
fn chart_move_event() -> event.Event {
  event.Widget(event.Move(
    target: event.EventTarget(
      window_id: "dashboard",
      id: "dashboard#binance\u{001F}BTCUSDT\u{001F}1m",
      scope: [],
      full: "dashboard#binance\u{001F}BTCUSDT\u{001F}1m",
    ),
    x: 400.0,
    y: 200.0,
    pointer: event.Mouse,
    finger: None,
    modifiers: event.modifiers_none(),
    captured: False,
  ))
}

fn export(tree: Node) -> Nil {
  let svg =
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\""
    <> fs(canvas_w)
    <> "\" height=\""
    <> fs(canvas_h)
    <> "\" viewBox=\"0 0 "
    <> fs(canvas_w)
    <> " "
    <> fs(canvas_h)
    <> "\" style=\"background:#12161c\">\n<rect width=\"100%\" height=\"100%\" fill=\"#12161c\"/>\n"
    <> case find_canvas(tree) {
      None -> "<!-- NO CANVAS -->"
      Some(canvas) -> string.join(list.map(canvas.children, layer_to_svg), "\n")
    }
    <> "\n</svg>\n"
  write_file("artifacts/glibe_runtime_tree.svg", svg)
  io.println(
    "exported runtime tree: " <> int.to_string(string.length(svg)) <> " chars",
  )
}

@external(erlang, "file", "write_file")
fn write_file(path: String, content: String) -> Nil

pub fn main() -> Nil {
  let assert Ok(instance) = glibe.start()
  let broker = id.string_to_broker_id("binance")
  let sym = symbol.string_to_symbol("BTCUSDT")
  let assert Ok(bars) = rest.fetch_klines("BTCUSDT", IntervalOneMinute, 60)
  io.println("fetched " <> int.to_string(list.length(bars)) <> " real bars")
  list.each(bars, fn(bar) {
    glibe.feed_sourcebar(instance, broker, sym, IntervalOneMinute, bar)
  })
  process.sleep(2000)
  case plushie.get_tree(instance) {
    Ok(Some(tree)) -> {
      export(tree)
      io.println(
        "DIAG crosshair before move = "
        <> int.to_string(count_layer_shapes(tree, "crosshair")),
      )
    }
    _ -> io.println_error("no tree")
  }
  // Dispatch a real pointer Move and re-check the crosshair layer: proves the
  // interaction reaches the widget through runtime routing, not just unit tests.
  plushie.dispatch_event(instance, chart_move_event())
  process.sleep(600)
  case plushie.get_tree(instance) {
    Ok(Some(tree)) ->
      io.println(
        "DIAG crosshair after move = "
        <> int.to_string(count_layer_shapes(tree, "crosshair")),
      )
    _ -> io.println_error("no tree after move")
  }
  let _ = plushie.stop(instance)
  Nil
}

import b_lustre
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

/// R24 / 04-04: one settled bar must be present in the JSON payload and in
/// the typed Lustre HTML page. Written before the rendering functions had bodies.
pub fn settled_bar_reaches_the_view_test() {
  let bar = b_lustre.settled_bar()
  assert string.contains(b_lustre.bar_to_json(bar), "123.5")
    as "the JSON endpoint must carry the settled close"
  assert string.contains(b_lustre.page(bar), "123.5")
    as "the Lustre HTML view must carry the settled close"
}

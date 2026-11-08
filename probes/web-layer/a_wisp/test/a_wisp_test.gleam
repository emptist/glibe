import a_wisp
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

/// R24 / 04-04: one settled bar must be present in BOTH the JSON endpoint's
/// payload and the HTML view. Written before `bar_to_json` and `page` had bodies.
pub fn settled_bar_reaches_the_view_test() {
  let bar = a_wisp.settled_bar()
  assert string.contains(a_wisp.bar_to_json(bar), "123.5")
    as "the JSON endpoint must carry the settled close"
  assert string.contains(a_wisp.page(bar), "123.5")
    as "the HTML view must carry the settled close"
}

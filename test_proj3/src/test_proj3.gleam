import gleam/list
import gleam/result
import gleam/io

pub fn main() {
  let bars = [1, 2, 3]
  let first_result = list.first(bars)
  case first_result {
    Ok(first) -> io.println("First: " <> gleam.int.to_string(first))
    Error(_) -> io.println("Error")
  }
}

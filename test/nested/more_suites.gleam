import bb
import gleam/int

pub fn another_suite() {
  bb.new_suite("Another suite")
  |> bb.add_tests([simple_assertion(), failing_assertion()])
}

fn simple_assertion() {
  use _ <- bb.test_case("Simple assertion")
  let x = 1
  let x_str = int.to_string(x)
  assert int.parse(x_str) == Ok(x)
}

fn failing_assertion() {
  use _ <- bb.test_case("Failing assertion")
  let x = 1
  let x_str = int.to_string(x)
  assert int.parse(x_str) == Error(Nil)
}

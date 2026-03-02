import bb
import gleam/io

pub fn main() -> Nil {
  bb.main()
}

pub fn greeting_suite() -> bb.TestSuite(String) {
  bb.new_suite("Greetings")
  |> bb.before_all(fn() { "World" })
  |> bb.add_tests([hello(), goodbye()])
}

fn hello() {
  use config <- bb.test_case("Hello Test")
  io.println("Hello, " <> config <> "!")
}

fn goodbye() {
  use config <- bb.test_case("Goodbye Test")
  let result = "Goodbye, " <> config <> "!"
  assert result == "Goodbye, World!"
}

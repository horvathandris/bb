import bb
import gleam/io

pub fn main() -> Nil {
  // bb.main()
  greeting_suite()
  |> bb.run()
}

pub fn greeting_suite() {
  bb.new_suite("Greetings", setup: fn() { "World" })
  |> bb.add_test(hello())
  |> bb.add_test(goodbye())
  |> bb.add_test(panic_test())
}

fn hello() {
  use config <- bb.test_case("Hello Test")
  io.println("Hello, " <> config <> "!")
}

fn goodbye() {
  use config <- bb.test_case("Goodbye Test")
  io.println("Goodbye, " <> config <> "!")
}

fn panic_test() {
  use config <- bb.test_case("Panic Test")
  panic as { "Panic, " <> config <> "!" }
}

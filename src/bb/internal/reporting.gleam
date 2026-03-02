import gleam/int
import gleam/io

pub type TestEvent {
  SuiteStarted(name: String)
  TestStarted(name: String)
  TestFinished(result: TestResult, duration: Int)
  SuiteFinished(name: String, passed: Int, failed: Int)
}

pub type TestResult {
  Passed
  Failed
}

pub fn consume_event(event: TestEvent) {
  io.println(event_to_string(event))
}

fn event_to_string(event: TestEvent) {
  case event {
    SuiteStarted(name) -> "suite started: " <> name
    TestStarted(name) -> "test started: " <> name
    TestFinished(Passed, duration) ->
      "test passed in: " <> int.to_string(duration) <> "ms"
    TestFinished(Failed, duration) ->
      "test failed in: " <> int.to_string(duration) <> "ms"
    SuiteFinished(name, passed, failed) ->
      "suite finished: "
      <> name
      <> ", passed: "
      <> int.to_string(passed)
      <> ", failed: "
      <> int.to_string(failed)
  }
}

import bb/internal/discovery
import bb/internal/reporting
import gleam/io
import gleam/list

pub fn main() -> Nil {
  discovery.find_suite_functions()
  |> create_and_run_suites
}

@external(erlang, "bb_ffi", "create_and_run_suites")
fn create_and_run_suites(
  modules: List(#(discovery.Module, discovery.Function)),
) -> Nil

pub opaque type TestCase(a) {
  TestCase(name: String, body: fn(a) -> Nil)
}

pub opaque type TestSuite(a) {
  TestSuite(
    name: String,
    tests: List(TestCase(a)),
    before_all: fn() -> a,
    before_each: fn(a) -> a,
    after_each: fn(a) -> Nil,
    after_all: fn(a) -> Nil,
  )
}

pub fn new_suite(name: String) -> TestSuite(Nil) {
  TestSuite(
    name,
    [],
    before_all: fn() { Nil },
    before_each: fn(config) { config },
    after_each: fn(_config) { Nil },
    after_all: fn(_config) { Nil },
  )
}

pub fn before_all(suite: TestSuite(Nil), body: fn() -> a) -> TestSuite(a) {
  TestSuite(
    suite.name,
    [],
    before_all: body,
    before_each: fn(config) { config },
    after_each: fn(_config) { Nil },
    after_all: fn(_config) { Nil },
  )
}

pub fn after_all(suite: TestSuite(a), body: fn(a) -> Nil) -> TestSuite(a) {
  TestSuite(..suite, after_all: body)
}

pub fn add_tests(suite: TestSuite(a), tests: List(TestCase(a))) -> TestSuite(a) {
  TestSuite(..suite, tests: list.reverse(tests) |> list.append(suite.tests))
}

pub fn add_test(suite: TestSuite(a), test_case: TestCase(a)) -> TestSuite(a) {
  TestSuite(..suite, tests: [test_case, ..suite.tests])
}

pub fn test_case(name: String, body: fn(a) -> Nil) -> TestCase(a) {
  TestCase(name, body)
}

pub fn run_suite(suite: TestSuite(a)) {
  let config = suite.before_all()
  list.reverse(suite.tests)
  |> list.each(fn(test_case) {
    let test_config = suite.before_each(config)
    reporting.consume_event(reporting.TestStarted(test_case.name))
    test_case.body(test_config)
    suite.after_each(test_config)
  })
  suite.after_all(config)
}

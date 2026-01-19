import gleam/list
import gleam/result
import gleam/string

pub fn main() -> Nil {
  let suites = []

  Nil
}

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
  let TestSuite(name, ..) = suite
  TestSuite(
    name,
    [],
    before_all: body,
    before_each: fn(config) { config },
    after_each: fn(_config) { Nil },
    after_all: fn(_config) { Nil },
  )
}

pub fn add_test(suite: TestSuite(a), test_case: TestCase(a)) -> TestSuite(a) {
  TestSuite(..suite, tests: [test_case, ..suite.tests])
}

pub fn test_case(name: String, body: fn(a) -> Nil) -> TestCase(a) {
  TestCase(name, body)
}

pub fn run(suite: TestSuite(a)) -> Nil {
  // TODO: make this private
  do_run(suite)
}

fn do_run(suite: TestSuite(a)) -> Nil {
  let config = suite.before_all()
  list.reverse(suite.tests)
  |> list.each(fn(test_case) {
    let test_config = suite.before_each(config)
    test_case.body(test_config)
    suite.after_each(test_config)
  })
  suite.after_all(config)
}

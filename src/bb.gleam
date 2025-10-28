import gleam/list

pub fn main() -> Nil {
  let suites = []

  Nil
}

pub opaque type TestCase(a) {
  TestCase(
    name: String,
    body: fn(a) -> Nil,
    setup: fn(a) -> a,
    teardown: fn(a) -> Nil,
  )
}

pub opaque type TestSuite(a) {
  TestSuite(
    name: String,
    tests: List(TestCase(a)),
    setup: fn() -> a,
    teardown: fn(a) -> Nil,
  )
}

pub fn new_suite(name: String, setup setup: fn() -> a) -> TestSuite(a) {
  TestSuite(name, [], setup: setup, teardown: fn(_config) { Nil })
}

pub fn add_test(suite: TestSuite(a), test_case: TestCase(a)) -> TestSuite(a) {
  TestSuite(..suite, tests: [test_case, ..suite.tests])
}

pub fn test_case(name: String, body: fn(a) -> Nil) -> TestCase(a) {
  TestCase(name, body, setup: fn(config) { config }, teardown: fn(_config) {
    Nil
  })
}

pub fn setup_test(test_case: TestCase(a), with body: fn(a) -> a) -> TestCase(a) {
  TestCase(..test_case, setup: body)
}

pub fn run(suite: TestSuite(a)) -> Nil {
  do_run(suite)
}

fn do_run(suite: TestSuite(a)) -> Nil {
  let config = suite.setup()
  list.reverse(suite.tests)
  |> list.each(fn(test_case) {
    let test_config = test_case.setup(config)
    test_case.body(test_config)
    test_case.teardown(test_config)
  })
  suite.teardown(config)
}

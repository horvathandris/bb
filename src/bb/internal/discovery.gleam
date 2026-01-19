import gleam/list
import gleam/result
import gleam/string

pub fn find_suite_functions() -> List(#(Module, Function)) {
  find_files(matching: "**/*.{erl,gleam}", in: "test")
  |> list.map(gleam_to_erlang_module_name)
  |> list.map(dangerously_convert_string_to_atom)
  |> list.flat_map(discover_suites)
}

fn gleam_to_erlang_module_name(path: String) -> String {
  case string.ends_with(path, ".gleam") {
    True ->
      path
      |> string.replace(".gleam", "")
      |> string.replace("/", "@")

    False ->
      path
      |> string.split("/")
      |> list.last
      |> result.unwrap(path)
      |> string.replace(".erl", "")
  }
}

pub type Atom

pub type Module =
  Atom

pub type Function =
  Atom

@external(erlang, "bb_discovery_ffi", "find_files")
fn find_files(matching matching: String, in in: String) -> List(String)

@external(erlang, "bb_discovery_ffi", "discover_suites")
fn discover_suites(module: Module) -> List(#(Module, Function))

@external(erlang, "erlang", "binary_to_atom")
fn dangerously_convert_string_to_atom(value: String) -> Atom

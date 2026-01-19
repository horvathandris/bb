-module(bb_ffi).
-export([create_and_run_suites/1]).

create_and_run_suites(ModuleAndFunctions) ->
    Suites = lists:map(
        fun({Module, Function}) ->
            Module:Function()
        end,
        ModuleAndFunctions
    ),
    lists:map(fun bb:run_suite/1, Suites).

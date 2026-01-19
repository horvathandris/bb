-module(bb_discovery_ffi).
-export([find_files/2, discover_suites/1]).

%% Find files matching a pattern in a directory
find_files(Pattern, In) ->
    Results = filelib:wildcard(binary_to_list(Pattern), binary_to_list(In)),
    lists:map(fun list_to_binary/1, Results).

%% Discover all functions returning bb:test_suite
discover_suites(Module) ->
    case get_module_ast(Module) of
        {ok, Forms} ->
            SuiteFunctions = extract_suite_functions(Forms),
            lists:map(
                fun(FunctionName) ->
                    {Module, FunctionName}
                end,
                SuiteFunctions
            );
        _ ->
            []
    end.

%% Get the abstract syntax tree for a module
get_module_ast(Module) ->
    case code:which(Module) of
        non_existing ->
            {error, module_not_found};
        preloaded ->
            {error, preloaded_module};
        cover_compiled ->
            {error, cover_compiled};
        BeamFile ->
            case beam_lib:chunks(BeamFile, [abstract_code]) of
                {ok, {Module, [{abstract_code, {raw_abstract_v1, Forms}}]}} ->
                    {ok, Forms};
                {ok, {Module, [{abstract_code, no_abstract_code}]}} ->
                    {error, no_debug_info};
                {error, beam_lib, Reason} ->
                    {error, Reason}
            end
    end.

%% Extract functions that have bb:test_suite return type
extract_suite_functions(Forms) ->
    lists:foldl(
        fun(Form, Acc) ->
            case Form of
                {attribute, _Line, spec, {{FunName, 0}, Specs}} ->
                    case returns_suite(Specs) of
                        true -> [FunName | Acc];
                        false -> Acc
                    end;
                _ ->
                    Acc
            end
        end,
        [],
        Forms
    ).

returns_suite(Specs) ->
    lists:any(
        fun(Spec) ->
            case Spec of
                {type, _Line, 'fun', [{type, _Line2, product, _Args}, ReturnType]} ->
                    is_test_suite_type(ReturnType);
                _ ->
                    false
            end
        end,
        Specs
    ).

is_test_suite_type({remote_type, _Line, [{atom, _L1, bb}, {atom, _L2, test_suite}, _TypeParams]}) ->
    true;
is_test_suite_type(_) ->
    false.

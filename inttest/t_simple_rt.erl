-module(t_simple_rt).

-compile(export_all).

files() ->
    [{copy,
        "../examples/simple", "simple"},
     {copy, "rebar.config", "simple/rebar.config"}].

run(_Dir) ->
    {ok, _} = retest:sh("rebar get-deps compile -v", [{dir, "simple"}]),
    true = filelib:is_regular("simple/deps/xml_writer/"
                                          "ebin/xml_writer.beam"),
    {ok, _} = retest:sh("rebar clean -v", [{dir, "simple"}]),
    true = filelib:is_regular("simple/deps/xml_writer/"
                                          "ebin/xml_writer.beam"),
    true = filelib:is_regular("simple/deps/hamcrest/"
                                        "ebin/hamcrest.beam"),
    ok.

%%
%% Generate the contents of a simple .app file
%%
app(Name, Modules) ->
    App = {application, Name,
           [{description, atom_to_list(Name)},
            {vsn, "1"},
            {modules, Modules},
            {registered, []},
            {applications, [kernel, stdlib]}]},
    io_lib:format("~p.\n", [App]).


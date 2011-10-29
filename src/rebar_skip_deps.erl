%% -----------------------------------------------------------------------------
%%
%% Copyright (c) 2011 Tim Watson (watson.timothy@gmail.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -----------------------------------------------------------------------------
-module(rebar_skip_deps).
-export([preprocess/2, postprocess/2]).

preprocess(Config, _) ->
    BaseDir = rebar_config:get_global(base_dir, undefined),
    rebar_log:log(debug, "Preprocessing...~n", []),
    Command = rebar_utils:command_info(current),
    %% Set/Reset skip_deps if explicitly configured to do so
    case skip_deps_for_command(Command, Config) of
        true ->
            rebar_log:log(debug, "Configured to skip_deps for ~p~n",
                          [Command]),
            %% using skip_deps doesn't work well, as we then have to
            %% set/reset skip_dir all over the place - we might as well
            %% do that to begin with...
            %% rebar_config:set_global(skip_deps, "true");

            %% first we need to skip any *external deps*
            Deps = rebar_config:get_local(Config, deps, []),
            [ skip_dir(code:lib_dir(App)) || {App, _Vsn} <- Deps ],

            %% now for the local deps
            DepsDir = rebar_config:get_global(deps_dir, "deps"),
            Cwd = rebar_utils:get_cwd(),
            case file:list_dir(DepsDir) of
                {ok, Files} ->
                    [ skip_dir(filename:join([Cwd, DepsDir, F])) ||
                                                        F <- Files ];
                _ ->
                    ok
            end,

            %% and finally, if the configuration requires it, we skip
            %% any subdirs that are explicitly requested by the user
            case rebar_config:get_local(Config, skip_subdirs, []) of
                [] ->
                    ok;
                Subdirs ->
                    [ skip_dir(Dir) || Dir <- Subdirs ]
            end;
        false ->
            ok
    end,
    {ok, []}.

postprocess(Config, _) ->
    rebar_log:log(debug, "Postprocessing...~n", []),
    Command = rebar_utils:command_info(current),
    DepsDir = rebar_config:get_global(deps_dir, "deps"),
    %% Set/Reset skip_deps if explicitly configured to do so
    case skip_deps_for_command(Command, Config) of
        true ->
            case file:list_dir(DepsDir) of
                {ok, Dirs} ->
                    %% why is there an API to skip, but not to *unskip* a dir?
                    [ erlang:erase({skip_dir, D}) || D <- Dirs ];
                _ ->
                    ok
            end;
        false ->
            ok
    end,
    {ok, []}.

skip_dir({error, _}) ->
    ok;
skip_dir(F) ->
    rebar_log:log(debug, "Skipping ~s~n", [F]),
    rebar_core:skip_dir(F).

skip_deps_for_command(Command, Config) ->
    GlobalSkip = rebar_config:get(Config, skip_dep_cmds, []),
    rebar_log:log(debug, "Global skip_dep_cmds: ~p~n", [GlobalSkip]),
    LocalSkip = rebar_config:get_local(Config, skip_dep_cmds, GlobalSkip),
    rebar_log:log(debug, "Local skip_dep_cmds: ~p~n", [LocalSkip]),
    lists:member(Command, LocalSkip).

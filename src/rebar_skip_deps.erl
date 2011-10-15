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

preprocess(_, _) ->
    Cmd = rebar_commands:current(),
    ExtraCommands = maybe_sanitize_destructive_command(Cmd),
    %% with a small patch, preprocess can now alter the command pipeline
    [ rebar_commands:enqueue_first(C) || C <- ExtraCommands ],
    {ok, []}.

postprocess(_, _) ->
    Skip = rebar_config:get_global(prev_skip_setting, undefined),
    case Skip of
        undefined ->
            ok;
        Setting ->
            reset_skip_deps(Setting)
    end,
    {ok, []}.

maybe_sanitize_destructive_command(Command) ->
    CommandString = atom_to_list(Command),
    case lists:suffix("-deps", CommandString) of
        false ->
            Skip = rebar_config:get_global(skip_deps, false),
            rebar_config:set_global(prev_skip_setting, Skip),
            rebar_config:set_global(skip_deps, "true"),
            %% no extra commands required
            [];
        true ->
            case lists:member(CommandString,
                              ["get-deps", "update-deps", "check-deps",
                               "list-deps", "delete-deps", "install-deps"]) of
                true ->
                    [];
                false ->
                    Parts = string:tokens(CommandString, "-"),
                    [_Deps|Rest] = lists:reverse(Parts),
                    NewCommand = string:join(Rest, "-"),
                    [NewCommand]
            end
    end.

reset_skip_deps(Skip) ->
    rebar_config:set_global(skip_deps, Skip).

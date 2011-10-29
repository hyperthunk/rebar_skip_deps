# Rebar skip_deps Plugin

This is an experimental plugin that re-implements https://github.com/basho/rebar/pull/73
as a pure plugin, without changing the default deps behaviour in rebar itself.

## Usage

Specify the commands for which you want to skip deps like so:

    {skip_dep_cmds, [clean, create]}.

If you also want to skip certain sub_dirs, you can configure this explicitly 
as well, and these will be added to the skip list along with any deps whenever
the commands you've configured to skip are being excluded.

```erlang
    %% this configuration will skip the `clean` and `create`
    %% commands in the deps/xml_writer and rel directories

    {deps, [{xml_writer, ".*"}]}.
    {skip_dep_cmds, [clean, create]}.
    {skip_subdirs, ["rel"]}.
```

## Important notes

This plugin is highly experimental and based on rebar features that have not 
made it into an official rebar branch (and may never do so).

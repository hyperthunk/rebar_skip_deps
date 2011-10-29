# Rebar skip_deps Plugin

This is an experimental plugin that re-implements https://github.com/basho/rebar/pull/73
as a pure plugin, without changing the default deps behaviour in rebar itself.

## Notices/Caveats

This plugin relies on a feature which is currently sitting in the official 
rebar repository as a pull request. Until this is merged, you will need to use
[this fork of rebar](https://github.com/hyperthunk/rebar/tree/pub-cmd-alt-deps)
in order to utilise the plugin. There is no guarantee that the pull request will
be accepted, so this plugin will remain *experimental* until such time as it is.

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

## Running the integration tests

You can run the integration tests by issuing the following command:

    $ ./rebar -C test.config get-deps compile retest -v

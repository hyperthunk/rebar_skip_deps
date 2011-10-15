# Rebar skip_deps Plugin

This is an experimental plugin that re-implements https://github.com/basho/rebar/pull/73
as a pure plugin, without changing the default deps behaviour in rebar itself.

## Usage

You can't currently utilise the plugin, as it relies on a feature change in
rebar_core which I haven't finished patching yet - namely, allowing plugins
(and other modules) to return additional commands from their `preprocess/2` 
implementation.

## Sample use case

I would like to be able to do this:

    $ rebar install-deps # maps get-deps compile-deps
    $ rebar create template=simplemod # ignored in deps
    $ rebar update-deps # updates them
    $ rebar compile-deps # compiles in any changes

## Important notes

This plugin is highly experimental and based on rebar features that have not made
it into an official rebar branch (and may never do so). You can play with this 
by looking at this rebar fork/branch:

- *TBC*

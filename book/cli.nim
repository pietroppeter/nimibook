import nimib, nimibook
import std / strformat

nbInit(theme = useNimibook)
nbText: fmt"""# Commands

With the `nimibookCli(book)` command at the end of `nbook.nim` file,
the executable is provided with a number of commands.
The help on the executable can be obtained running `nbook` without arguments:

```
{cliHelp}
```

## Customize nim compile time parameters

During build nimibook compiles and runs a `example.nim` file
with `nim r <nimOptions> <srcDir>/example.nim`.
Any additional argument after `build` is used as-is in `<nimOptions>`.

For example to compile the whole book in release mode with no hints
or other messages from the compiler you can run:

```
nbook build -d:release --hints:off --verbosity:0
```

## Single nimib document build

When you are working on a single nimib document you are not interested in
building the complete book. In order to build a single file
you need first to dump the `book.json` with `nbook dump`.
After this is done you can build the single `example.nim` file
as you would with standard nimib. For example to show it in the browser after
build is completed you can run:

```
nim r book/example.nim --nbShow
```

## Parallel build and error logs

By default nimibook builds source files in parallel.
If an error is produced when building a source file a `.log` file
with the output of build command is created next to source file.

If you need to disable the parallel builds you can set
`-d:nimibParallelBuild=false` when compiling `nbook`.

By default it builds up to a maximum of 10 source files in parallel.
To change the default maximum to `n` you can set
`-d:nimibMaxProcesses=n` when compiling `nbook`.

"""
nbSave

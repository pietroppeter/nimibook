# Code guide

Code in nimibook serves two purposes:

1. code to implement a CLI to manage the book (init, build, ...)
2. code for the theme to be used in every chapter (page) of the book

A special role is played by the Table of Contents (TOC), which
is needed both by the CLI and by each page.

Currently the CLI has to be generated in a custom file
where the TOC is also specified (default name: `nbook.nim`).
In the future it is possible that nimibook will come with its own
prebuilt `nbook` binary and Toc will be defined elsewhere
(e.g. with a SUMMARY.md as in mdbook).

To make the TOC available for every page, the `Book` object
(created by the CLI) is serialized as `book.json`.

Summary content of the various files:

- `src\nimibook.nim`:
  - imports and exports for public api
  - CLI parser
- `src\nimibook\types.nim`: the types (`Book`, `Toc`, `Entry`)
- `src\nimibook\tocs.nim`: template DSL to specify a TOC (and generate a `Book` object)
- `src\nimibook\entries.nim`: utility functions for `Entry` object (an entry is a element of the Toc, aka chapter)
- `src\nimibook\renders.nim`: function to render `Toc` object as a mustache partial (to be used in every page)
- `src\nimibook\theme.nim`:
  - implements `useNimibook` theme function to be used in every page
  - contains `document` partial (the mustache template for every page)
- `src\nimibook\assets\`: a folder where all the assets (css, js, fonts) reside
- `src\nimibook\assets.nim`: function to initialize and update assets
- `src\nimibook\defaults.nim`: default values for `Book` object
- `src\nimibook\commands.nim`: implementations for all commands used by the CLI except build
- `src\nimibook\builds.nim`: implementation for build command
- `src\nimibook\paths.nim`: utilities for path handling (used only in `tocs.nim`)
- `src\nimibook\sort.nim`: utilities for sorting entries. Currently not used, could be used in the future to sort entries generated automatically from a folder.

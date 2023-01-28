# Changelog

## v0.3.0 (July 2022)

* update to use nimib 0.3 and maintenance (#50):
  - fix usage of `blocks` context in `document` template update to reflect change in nimib 0.3
  - `nimib.toml` now supports configuration for the book,
    no need anymore to specify the configuration inside a nbook.nim file
  - ...
  - templates folder changed to `srcDir / templates`
* fix next/previous buttons when there is a draft chapter (see [commit 428e482](https://github.com/pietroppeter/nimibook/commit/428e482ac7b86e4f12c5ca8c79e419cb47250ea7))
* add latex support using katex (activated with `nb.useLatex` as in standard nimib), see #52
* made building happen async and in multiple process (see #53):
  - this improves the speed of building nimibook
  - in case there is an error when building a specific entry a `.log` file is created next to the entry which contains the log of failure
* add deploy previews through netlify (#55)
* improve documentation to track recent changes and add a changelog (#56)

## v0.2.1 (November 2021)

* bugfix release to fix path handling (see #42), linked to equivalent bugfix release in nimib 0.2.1

## v0.2.0 (November 2021)

No official tagged release of 0.1, making 0.2 the first official release of nimibook.

* nimibook 0.2 is based of nimib 0.2 (the "Theme Maker" release), which makes available the `nb` global object
  that simplifies creation of themes.
* nimibook is started as a port of [mdbook](https://rust-lang.github.io/mdBook/index.html) to nim and as such it is based off mdbook templates
  and replicates mdbook features. Among these features are:
  - book format with a foldable table of contents on the side
  - multiple themes (Light, Rust, Coal, Navy, Ayu)
  - book page can be created from markdown
  - link to github repo
  - next/previous page buttons
* nimibook is also specific for nim and it diverges from mdbook in these details:
  - a book page can be created using nimib with `nbInit(theme = useNimibook)`
  - the command to manage the book must be customized, compiled and run in the book project (no universal `nimibook` binary for now)
  - the toc is specificied inside the binary used to build the book
* nimibook thus provides library features to build your book building features and in particular it provides:
  - a `useNimibook` theme to use in nimib documents
  - a `newBookFromToc` DSL to create a table of contents that supports `section` (a chapter that opens indented chapters),
    `entry` (a standard numbered entry), `draft` (a placeholder for non existent entry)
  - a `nimibookCli` template to create a CLI that supports the following commands:
    + `help`: prints help and all available commands
    + `init`: to initialize a book with structure and assets (mustache templates, css styles, javascript, fonts)
    + `update`: to update assets in case they change
    + `build`: builds the book by rendering all toc entries
    + `check`: checks that all entries that are supposed to be built have been created
    + `clean`: removes all files generated from a build command
    + `dump`: creates and dumps a `book.json` object that contains table of contents and all the shared data that is needed to build a single page with nimib
* you can still use standard nim with `nim r book/entry.nim` to build a single page, provided that you have dumped a `book.json`
* being based on nimib 0.2, nimibook requires the existence of a `nimib.toml` configuration file where a `srcDir` (folder with sources for entries)
  and a `homeDir` (folder where the book will be built) are defined

## v0.1 (May-June 2021)

The main driving force for the development of nimibook since the beginning has been to support [scinim/getting-started](https://github.com/SciNim/getting-started)
a collection of tutorials to use Nim for Scientific Computing.
The initial idea of using nimib for SciNim came from @HugoGranstrom in
scinim/getting-started's [first issue](https://github.com/SciNim/getting-started/issues/1#issuecomment-837266835) (May 2021),
the idea was then further discussed in a [nimib's issue](https://github.com/pietroppeter/nimib/issues/40).
After an initial proof of concept by @pietroppeter, most of the development during 0.1 was done by @Clonkk.

The version of mdbook on which nimibook is based is likely [mdbook v0.4.8](https://github.com/rust-lang/mdBook/tree/v0.4.8) released in May 2021
(this is deduced from when the initial development started).
# Changelog

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
* nimibook is also specific for nim and it diverges from mdbook in these details:
  - a book page can be created using nimib with `nbInit(theme = useNimibook)`
  - the command to manage the book must be customized, compiled and run in the book project (no universal `nimibook` binary for now)
  - the toc is specificied inside the binary used to build the book
* nimibook thus provides library features to build your book building features and in particular it provides:
  - a `useNimibook` theme to use in nimib documents
  - a `newBookFromToc` DSL to create a table of contents which supports, section (a chapter that opens indented chapters), entry (a standard numbered entry), draft (a placeholder for non existent entry)
  - a `nimibookCli` template to create a CLI that supports the following commands:
    + `init`: to initialize a book with structure and assets (mustache templates, css styles, javascript, fonts)
    + `update`: to update assets in case they change
    + `build`: builds the book by rendering all toc entries
    + `clean`: removes all files generated from a build command
    + `dump`: creates and dumps a `book.json` object that contains table of contents and all the shared data that is needed to build a single page with nimib
* you can still use standard nim with `nim r book/entry.nim` to build a single page, provided that you have dumped a `book.json`
* being based on nimib 0.2, nimibook requires the existence of a `nimib.toml` configuration file where a `srcDir` (folder with sources for entries)
  and a `homeDir` (folder where the book will be built) are defined
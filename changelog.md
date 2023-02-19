# Changelog

## v0.3.0 (February 2023)

* Improved docs and nim 2.0 compatibility (added to CI) (#56). other minor changes:
  - updated CI to test on 1.6.x, devel, stable
  - improve nbook help (document dump and build options)
  - remove the rust file in assets/fonts
  - add as vendored the assets (css, font and js stuff)
* Parallel build fixes (#61)
  * Fixed parallel build so it uses the correct folder for saving log files.
  * The error messages are printed to terminal as well
  * Pass compiler flag `-d:nimibParallelBuild=false` to compile in serial.
  * Pass `-d:nimibMaxProcesses=n` to run at most `n` builds in parallel at a time (default is 10)
* The next-arrow is shown correctly on the second to last page.  (#61)
* update to use nimib 0.3 and lots of maintenance (#50) including some breaking changes and some additional features:
  - fix usage of `blocks` context in `document` template update to reflect change in nimib 0.3
  - `nimib.toml` now supports configuration for the book (in a [nimibook] section),
    no need anymore to specify the configuration inside a nbook.nim file:
    - in particular now you can specify the name of folder for source and build of book, fixes #48
  - `book.json` is now published in docs folder and can work as a  static api
  - removed default options from build command (they were `"-d:release", "-f", "--verbosity:0", "--hints:off"`);
    build command now supports options that are passed to nim compiler
    - also now build fails at the end
  - init command now creates default sources for toc elements (in particular it creates a default nimib document that uses nimibook)
  - mustache templates are now in-memory partials, fixes #32
  - removed book source folder in toc (taken from config) and removed `path` field from `Toc` object
  - minor breaking changes:
    - templates folder changed to `srcDir / templates`
    - remove `nbUseNimibook` (use `nbInit(theme = useNimibook)`)
    - `newBookFromToc` deprecated and replaced with `initBookWithToc`
    - various changes to `Book` type:
      - refactored `Book.book_title` into `Book.title`. Overrides previously existing `Book.title` which was supposed to be used for the Chapter title (not used)
      - removed `book.path_to_root` (it is a document/chapter thing)
  - default title for a page is now entry title/label, fix #46 
  - rename and fix of draft entry, fix #44
    - also fix for init and build when entry is a draft (skip)
  - improved check command, fails after checking both sources and output and reports failures
  - general code refactoring. code structure is now documented in a readme.md inside src folder:
    - asset management moved to `assets` module and default assets moved in source
    - books and docs module removed and new modules builds, commands and configs added
  - renames examples to example_book and improved example
  - added unit tests, which are added to CI and we also test example book
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
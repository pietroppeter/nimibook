# nimibook

**nimibook** is a port of [mdbook] to [Nim], powered by [nimib].
Nimibook allows to create a nice looking book from nim code and markdown,
making sure that nim code is running correctly and being able to incorporate code outputs in the final book.
An example book is [nimibook documentation][nimibook] itself.

[mdBook] is a command line tool and Rust crate to create books
using Markdown (as by the CommonMark specification) files.
It's very similar to [Gitbook], which is a command line tool (and Node.js library)
for building beautiful books using GitHub/Git and Markdown (or AsciiDoc).

[nimib] is a Nim library to convert your Nim code and its outputs to html documents.
The html output can be easily customized thanks to [nim-mustache],
and this is what allows it to use it to build nimibook.
_nimib documents_ are normal nim files which use nimib library to produce an output document.

The Markdown dialect supported by both nimib and nimibook is the subset of [Github Flavored Markdown][GFM]
provided by [nim-markdown]. For a quick reference of supported syntax see the [cheatsheet].

### Status

nimibook currently provides minimal functionality to create a book and support a local CLI mode.

## Installation

To install Nimibook simply use : `nimble install nimibook`

## Usage

1. Write your content using [nimib] or simple markdown files in the `book` folder.
   The basic template for an empty page is:
```nim
import nimib, nimibook

nbInit(theme = useNimibook)
# content here
nbSave
```

2. Use the Table of Content (ToC) DSL to link chapters to content in `nbook.nim`.
Example : 
```nim
import nimibook

# Create a new book called "Dummy", whose content is in the folder "book"
var book = newBookFromToc("Dummy Book", "book"):
  # Create a new section called "Dummy", its content is the file "index.nim"
  section("Dummy", "index"): # Note how the .nim extensions is optional
    # Create a new entry called "Simple example", its content is the file "page_1.nim"
    entry("Simple example", "page_1.nim")

# access to nimibook cli which will allow to build the book
nimibookCli(book)
```
See [nimibook] or [Nimibook repo](https://github.com/pietroppeter/nimibook
) for more documentations and examples.

3. Generate your very own CLI tools or use Nimble tasks with `nim c -d:release nbook.nim`.
  * `./nbook init` to init your book structure. **This command must be ran at least once**. 
  * `./nbook build` to build your book.

4. Whenever your Table of Content changes (add/remove files, changes sections organization), recompile your `nbook` and run the `build` command : `nim c -d:release nbook.nim && ./nbook build`
  * It is also doable in one command : `nim r -d:release nbook.nim build`
  * You don't need to call the `init` command again.
  * Rinse and repeat until your ToC is done ! Then you can just edit files and call `build` without recompiling.

## Tips and Tricks 

* to build a single page (e.g. `book/mypage.nim`) run first `./nbook dump`
(which dumps a `book.json` file that contains a table of contents and other context data).
If `book.json` is present, then you can build your page with: `nim r book/mypage.nim`
* Each book requires its own ToC and thus will be its own CLI Apps
* `nbook.nim` is the default name used - it is possible to use another name.
* Multiple books `nbook.nim` cannot share the same folder. Instead, either split them into two separate books, or merge them into one.
* Some commands : 
  * `./nbook clean` will remove generated files and restart from a clean state.
  * `./nbook update` will update assets and mustache template.
  * These two commands will modify installed files, use them with caution if you customized files locally.

### Analytics

This website is tracking analytics with [plausible.io](https://plausible.io/index.html), a lightweight and open-source website analytics tool with no cookies and fully compliant with GDPR, CCPA and PECR.
Analytics for this website are publicly available [here](https://plausible.io/pietroppeter.github.io%2Fnimibook). You can opt out from analytics tracking with [standard ad-blocking](https://plausible.io/docs/excluding) or typing [`localStorage.plausible_ignore=true`](https://plausible.io/docs/excluding-localstorage) in browser console.

<!--refs-->
[mdbook]: https://rust-lang.github.io/mdBook/index.html
[Nim]: https://nim-lang.org/
[nimib]: https://pietroppeter.github.io/nimib/
[Gitbook]: https://github.com/GitbookIO/gitbook
[nim-mustache]: https://github.com/soasme/nim-mustache
[nimibook]: https://pietroppeter.github.io/nimibook/
[GFM]: https://github.github.com/gfm/
[nim-markdown]: https://github.com/soasme/nim-markdown

##

<!--SKIP
All content before this sign is replicated in the Introduction chapter of nimibook documentation
-->

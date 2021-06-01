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

nimibook currently provides minimal functionality to create a book, notably missing is
a command line interface to automate common task (e.g. initialization of a new nimibook).

## Installation

To be able to use nimibook, currently the only way is to recreate the same content of the repository
and adjust it to your content. You can do that using the template feature from github
or with a checkout of the repo and copying and pasting.

Discussion of further options is ongoing in [issue #12](https://github.com/pietroppeter/nimibook/issues/12).

## Usage

1. Write your content using [nimib] or simple markdown files in the ``book`` folder.
2. Use the Toc DSL to link chapters to content in ``genbook.nim``.
3. Generate your books in the ``docs`` folder using ``nimble genbook``.

<!--refs-->
[mdbook]: https://rust-lang.github.io/mdBook/index.html
[Nim]: https://nim-lang.org/
[nimib]: https://pietroppeter.github.io/nimib/
[Gitbook]: https://github.com/GitbookIO/gitbook
[nim-mustache]: https://github.com/soasme/nim-mustache
[nimibook]: https://pietroppeter.github.io/nimibook/
[GFM]: https://github.github.com/gfm/
[nim-markdown]: https://github.com/soasme/nim-markdown

<!--SKIP
All content before this sign is replicated in the Introduction chapter of nimibook documentation
-->

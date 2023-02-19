# nimibook

**nimibook** is a port of [mdbook] to [Nim], powered by [nimib].
Nimibook allows to create a nice looking book from nim code and markdown,
making sure that nim code is running correctly and being able to incorporate code outputs in the final book.
An example book is [nimibook] documentation.

> [mdBook] is a command line tool and Rust crate to create books
> using Markdown (as by the CommonMark specification) files.
> It's very similar to [Gitbook], which is a command line tool (and Node.js library)
> for building beautiful books using GitHub/Git and Markdown (or AsciiDoc).

[nimib] is a Nim library to convert your Nim code and its outputs to html documents.
The html output can be easily customized thanks to [nim-mustache],
and this is what allows it to use it to build nimibook.
_nimib documents_ are normal nim files which use nimib library to produce an output document.

One particular advantage of nimib is that it can incorporate interactive content
taking advantage of nim's js backend.
For the basic examples see
[nimib interactivity doc](https://pietroppeter.github.io/nimib/interactivity.html).

The Markdown dialect supported by both nimib and nimibook is the subset of [Github Flavored Markdown][GFM]
provided by [nim-markdown]. For a quick reference of supported syntax see this [cheatsheet] (created with nimib).

<!--refs-->
[mdbook]: https://rust-lang.github.io/mdBook/index.html
[Nim]: https://nim-lang.org/
[nimib]: https://pietroppeter.github.io/nimib/
[Gitbook]: https://github.com/GitbookIO/gitbook
[nim-mustache]: https://github.com/soasme/nim-mustache
[nimibook]: https://pietroppeter.github.io/nimibook/
[GFM]: https://github.github.com/gfm/
[nim-markdown]: https://github.com/soasme/nim-markdown
[cheatsheet]: https://pietroppeter.github.io/nimib/cheatsheet.html

## Status

Nimibook is actively maintained ([target issues for 2023](https://github.com/pietroppeter/nimibook/issues?q=is%3Aopen+is%3Aissue+label%3A2023H1%2C2023H2))
and it provides the basic functionality
needed to create a book with markdown and nimib sources.
It still has some features missing from mdbook
(see [this issue](https://github.com/pietroppeter/nimibook/issues/9#issuecomment-851989939)).

To follow up on recent changes check the [changelog.md](https://github.com/pietroppeter/nimibook/blob/main/changelog.md).

## Example sites using nimibook

- [scinim/getting-started](https://scinim.github.io/getting-started/)
- [moigagoo/norm](https://norm.nim.town)
- [PhilippMDoerner/Snorlogue](https://philippmdoerner.github.io/Snorlogue/bookCompiled/)

You are welcome to open a PR and add your site using nimibook here.

## Features

- table of contents in a collapsible sidebar
- five themes (Light, Rust, Coal, Navy, Ayu)
- buttons to next/previous pages
- build multiple files in parallel
- (optional) latex content with katex
- (optional) link to github repo
- (optional) link to track analytics with plausible analytics

## Installation

To install Nimibook: `nimble install nimibook`

## How to setup your book with nimibook

Nimibook does not ([yet](https://github.com/pietroppeter/nimibook/issues/63)) provides an executable to manage your book, but it provides the basic building blocks to write your own.

**1. example nbook.nim**: in a folder of your choice create a `nbook.nim` file with the following content:

```nim
import nimibook

var book = initBookWithToc:
  entry("Preface", "preface.md", numbered = false)
  entry("Introduction", "intro.md")
  section("Chapter 1", "chapter1/index.nim"):
    entry("Content", "content.nim")
    draft("Nothing yet")
    section("Sub chapter", "no_ext"):
      entry("and some more content", "more.md")

nimibookCli(book)
```

**2. write a TOC**: modify `nbook.nim` to specify
the planned Table of Content (TOC) for your book.

**3. nbook init**: running `nim r nbook init` (or compile `nbook` and run `nbook init`) will set up the book with:
- a `nimib.toml` that contains the default configuration for the book
- a `book` folder that contains sources for all chapters mentioned in the TOC. Note that `.nim` files already contain default `nimib` content to be used in nimibook. 
- a `docs` folder that contains static assets for the book
and that will contain the built book

**4. nbook build**: run `nim r nbook build` to build the book. Open any `.html` file in `docs` folder to navigate your book.

**5. create your content and enjoy!**: now you are ready to start creating content in your sources and publish your book.

<!--SKIP
All content before this sign is replicated in the Introduction chapter of nimibook documentation
-->

See [nimibook] documentation for more details.

## Contribute

You are more than welcome to contribute!

- We usually have some open issues of stuff we need to fix or we would like to do.
- You have an overview of the code base in [src/readme.md](src/readme.md)
- The CI is setup to run tests and publish a document PR preview (click on details on the Netlify preview task once it's green), so that we can all check the changes directly from the PR.
- You should also test and build the book locally, there are nimble tasks to help with that (run `nimble tasks` for the list).
- If the feature can be tested with a unit test, make sure to add one.
- Once you make a change, remember to document your changes in the appropriate place in the docs.
- If you add a module, remember to update the code guide.
- bump the version (usually a patch increment) so that we can immediately tag and release your contribution.
- Make sure that the title of your PR is clear and edit the initial message with a few short sentences that will be added to the changelog once we release. 

## Analytics

This website is tracking analytics with [plausible.io](https://plausible.io/index.html), a lightweight and open-source website analytics tool with no cookies and fully compliant with GDPR, CCPA and PECR.
Analytics for this website are publicly available [here](https://plausible.io/pietroppeter.github.io%2Fnimibook). You can opt out from analytics tracking with [standard ad-blocking](https://plausible.io/docs/excluding) or typing [`localStorage.plausible_ignore=true`](https://plausible.io/docs/excluding-localstorage) in browser console.

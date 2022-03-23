import nimib / types
import std / [tables, os]
export tables
import macros

type
  Entry* = object
    title*: string
    path*: string
    levels*: seq[int]
    isNumbered*: bool
    isDraft*: bool
    isActive*: bool
  Toc* = object
    entries*: seq[Entry]
  BookConfig* = object ## All the fields in this object can be set from Toml configuration in a [nimibook] section
    title*: string ## Title of the book
    language*: string ## The main language of the book, which is used as a language attribute `<html lang="en">` for example (defaults to en)
    description*: string ## A description for the book, which is added as meta information in the html <head> of each page
    default_theme*: string ## The theme color scheme to select by default in the 'Change Theme' dropdown. Defaults to light.
    preferred_dark_theme*: string ## The default dark theme. This theme will be used if the browser requests the dark version of the site via the ['prefers-color-scheme'](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme) CSS media query. Defaults to navy.
    git_repository_url*: string ## A url to the git repository for the book. If provided an icon link will be output in the menu bar of the book.
    git_repository_icon*: string ## The FontAwesome icon class to use for the git repository link. Defaults to `fa-github`.
    plausible_analytics_url*: string ## (new in nimibook) if non empty it will include plausible analytics script in every page.
    favicon_escaped*: string ## (new in nimibook) provide your fully custom `<link rel="icon" href="...">`. defaults to whale emoji as in nimib.
  Book* = object
    initDir*: AbsoluteDir
    cfgDir*: AbsoluteDir
    rawCfg*: string
    nbCfg*: NbConfig
    cfg*: BookConfig
    theme_option*: Table[string, string] # cannot find it mentioned in mdbook docs. by default is a Table with available themes and their names.
    toc*: Toc
    keep*: seq[string] # used in commands.shouldDelete but unclear if it is really used or not

template expose(ObjType, cfg, field, FieldType: untyped) =
  template `field`*(o: ObjType): FieldType =
    o.`cfg`.`field`

  template `field =`*(o: var ObjType, v: FieldType) =
    o.`cfg`.`field` = v

macro expose(ObjType, myCfg, body: untyped) =
  #echo body.treerepr
  result = newStmtList()
  for arg in body:
    doAssert arg.kind == nnkCall
    let f = arg[0]
    let typ = arg[1][0] # [1] is nnkStmtList w/ 1 element
    result.add quote do:
      expose `ObjType`, `myCfg`, `f`, `typ`
    #echo arg.treerepr
  #echo result.repr

# thanks to vindaar, see https://stackoverflow.com/q/71459423/4178189
expose(Book, cfg):
  title: string
  language: string
  description: string
  default_theme: string
  preferred_dark_theme: string
  git_repository_url: string
  git_repository_icon: string
  plausible_analytics_url: string
  favicon_escaped: string

# srcDir and homeDir should be given as relative to cfgDir
proc srcDir*(book: Book): string = book.nbCfg.srcDir
proc homeDir*(book: Book): string = book.nbCfg.homeDir

#[
documentation for mdbook is in this two pages:
  - https://rust-lang.github.io/mdBook/format/theme/index-hbs.html
  - https://rust-lang.github.io/mdBook/format/config.html

here is the list index.hbs adapted from mdbook to mustache
current list is what I have not yet put in Book object:
- is_print
- base_url
- favicon_svg/favicon_png
- print_enable
- additional_css
- mathjax_support
- search_enable
- git_repository_edit_url
- previous (link)
- next (link)
- livereload
- google_analytics
- playground_line_numbers
- playground_copyable
- playground_js
- search_js
- additional_js

these are partials that were referred in original index.hbs:
- head (also in document.mustache)
- header (also in document.mustache)
- toc (it was handlebar helper and it is handled differently in nimibook)

list of assets required as mentioned directly in document.mustache (other assets might be mentioned elsewhere - e.g. in css):
- css/variables.css
- css/general.css
- css/chrome.css
- FontAwesome/css/font-awesome.css
- highlight.css
- tomorrow-night.css
- ayu-highlight.css
- clipboard.min.js
- highlight.js
- book.js

]#

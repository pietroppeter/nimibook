import tables
export tables

type
  Entry* = object
    title*: string
    path*: string
    levels*: seq[int]
    isNumbered*: bool
    isActive*: bool
  Toc* = object
    path*: string
    entries*: seq[Entry]
  Book* = object
    # for consistency with template values, we use snake case for fields of this object
    # if not indicated otherwise, these fields are present in document.mustache and they are directly adapted from index.hbs
    # documentation for mdbook is in this two pages:
    #   - https://rust-lang.github.io/mdBook/format/theme/index-hbs.html
    #   - https://rust-lang.github.io/mdBook/format/config.html
    # sometimes a field appears in both places with different descriptions (e.g. language)
    # documentation comments below come directly from mdbook documentation (unless otherwise stated)
    #
    # required fields (in the sense the mustache template will work bad if they are not present):
    book_title*: string ## Title of the book as specified in `newBookFromToc`
    # chapter_title: not needed? 
    title*: string # title of the page (what appears in browser tab); default in mdbook is "<chapter_title> - <book_title>" where chapter_title comes from toc
    language*: string ## The main language of the book, which is used as a language attribute `<html lang="en">` for example (defaults to en)
    description*: string ## A description for the book, which is added as meta information in the html <head> of each page
    path_to_root*: string ## This is a path containing exclusively `../`'s that points to the root of the book from the current file. Since the original directory structure is maintained, it is useful to prepend relative links with this `path_to_root`.
    default_theme*: string  ## The theme color scheme to select by default in the 'Change Theme' dropdown. Defaults to light.
    preferred_dark_theme*: string ## The default dark theme. This theme will be used if the browser requests the dark version of the site via the ['prefers-color-scheme'](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme) CSS media query. Defaults to navy.
    theme_option*: Table[string, string] # cannot find it mentioned in mdbook docs. by default is a Table with available themes and their names.
    # optional stuff:
    git_repository_url*: string ## A url to the git repository for the book. If provided an icon link will be output in the menu bar of the book.
    git_repository_icon*: string ## The FontAwesome icon class to use for the git repository link. Defaults to `fa-github`.
    favicon_escaped*: string ## (new in nimibook) provide your fully custom `<link rel="icon" href="...">. defaults to whale emoji as in nimib.
    # toc object. in mdbook there is a similar `chapters` field but toc is handled differently anyway. not present in document.mustache
    toc*: Toc


#[
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
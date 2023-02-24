import std / [os, parseopt, sequtils]
export os, parseopt

import nimibook / [types, toc_render, toc_dsl, builds, defaults, themes, commands, configs]
export types, toc_render, toc_dsl, builds, defaults, themes, commands

import nimib / paths

template nbUseNimibook* =
  {. error: "nbUseNimibook has been removed in nimibook 0.3, use nbInit(theme = useNimibook)" .}

# stop at the sign in order to make sure it shows without scroll in nimibook:              V
const cliHelp* = """
Choose one of the following options : init, build, dump, check, clean, update
init   : Initialize book structure:
         - creates a default nimib.toml config (if not already present)
         - creates required nimibook assets in output folder (if not already present)
         - creates default sources file for entries listed in toc
         After first usage it can be used to create source files from ToC
build  : Build your complete book.
         You can add options (e.g. --verbosity:0, -d:release, ...)
         and they will be passed when compiling and running nimib documents
dump   : dump the content of book.json (required to build single documents)
check  : Check that sources and outputs are present as expected in ToC.
clean  : Removes (almost) everything from output folder except assets.
update : Update assets (css, js, fonts) in case they changed in last nimibook release.
"""

proc nimibookCli*(book: var Book) =
  book.initDir = getCurrentDir().AbsoluteDir
  echo "[nimibook] setting current directory to cfgDir: ", book.cfgDir.string
  setCurrentDir(book.cfgDir.string)
  var p = initOptParser()
  var hasArgs = false
  while true:
    p.next()
    case p.kind
    of cmdEnd:
      if not hasArgs:
        echo cliHelp
      break
    of cmdShortOption, cmdLongOption:
      discard
    of cmdArgument:
      hasArgs = true
      if p.key == "init":
        init book
      elif p.key == "clean":
        clean book
      elif p.key == "check":
        check book
      elif p.key == "build":
        # TODO specify folder in options
        let nimOptions = commandLineParams().filterIt(it != "build")
        build book, nimOptions
      elif p.key == "update":
        update book
      elif p.key == "dump":
        dump book
      else:
        echo cliHelp

proc initBook*: Book =
  result.loadConfig
  result.setDefaults

template initBookWithToc*(body: untyped): Book =
  var book = initBook()
  book.toc = initToc:
    body
  # echo book.renderToc
  book

# deprecated: api superseded by config based api (and wrong use of New)
template newBookFromToc*(bookTitle: string, rootDir: string, body: untyped): Book =
  echo "[nimibook.warning] newBookFromToc is deprecated in 0.3, use initBookFromToc"
  var book = initBookWithToc:
    body
  book.title = bookTitle
  if book.nbCfg.srcDir != rootDir:
    echo "[nimibook.error] srcDir in config (", book.srcDir , ") different from srcDir from newBookFromToc: ", rootDir
    quit(1)
  book
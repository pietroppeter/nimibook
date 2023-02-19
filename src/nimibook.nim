import std / [os, parseopt, sequtils]
export os, parseopt

import nimibook / [types, renders, tocs, builds, defaults, themes, commands, configs]
export types, renders, tocs, builds, defaults, themes, commands

import nimib / paths

template nbUseNimibook* =
  {. error: "nbUseNimibook has been removed in nimibook 0.3, use nbInit(theme = useNimibook)" .}

proc printHelp() =
  echo """
Choose one of the following options : init, clean, check, build, update
init   : Initialize book structure.
build  : Build your book.
         You can add options (e.g. --verbosity:0, -d:release)
         and they will be passed when compiling and running nimib documents
dump   : dump the content of book.json (required to build single documents)
clean  : Delete generated files and files that are not supposed to be here (use this with caution).
check  : Check generated book is correct.
update : Update assets (css, js, fonts).
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
        printHelp()
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
        printHelp()

proc initBook*: Book =
  result.loadConfig
  result.setDefaults

template initBookWithToc*(body: untyped): Book =
  var book = initBook()
  book.toc = initToc:
    body
  echo book.renderToc
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
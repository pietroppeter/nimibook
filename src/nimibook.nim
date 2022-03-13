import nimibook / [types, render, tocs, publishers, defaults, theme, commands]
export types, render, tocs, publishers, defaults, theme, commands

template nbUseNimibook* =
  nb.useNimibook

proc printHelp() =
  echo """
Choose one of the following options : init, clean, check, build, update
init   : Initialize book structure.
clean  : Delete generated files and files that are not supposed to be here (use this with caution).
check  : Check generated book is correct.
build  : Build your book !
update : Update assets and mustache template.
"""

import std/[os, parseopt]
export os, parseopt
template nimibookCli*(book: Book) =
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
        publish book
      elif p.key == "update":
        update book
      elif p.key == "dump":
        dump book
      else:
        printHelp()

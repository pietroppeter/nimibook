import nimibook / [types, render, tocs, publishers, defaults, docs, books]
export types, render, tocs, publishers, defaults, docs, books

template nbUseNimibook* =
  nbDoc.useNimibook

proc printHelp() =
  echo """
Choose one of the following options : init, clean, check, build, update
init   : It init stuff. Do it at least once.
clean  : delete files that are generated or not supposed to be here
check  : check stuff is correct
build  : It build your book ? Really, what else did you expect...
update : It update stuff.
"""

template nbBookTasks* =
  import parseopt
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

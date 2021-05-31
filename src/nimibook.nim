import nimibook / [types, render, tocs, publishers, defaults]
export types, render, tocs, publishers, defaults

template nbUseNimibook* =
  nbDoc.useNimibook

template nbBookTasks* =
  when defined(printBook):
    import print
    print book
  elif defined(dumpBook):
    dump book
  elif defined(cleanBook):
    clean book
  else:
    publish book

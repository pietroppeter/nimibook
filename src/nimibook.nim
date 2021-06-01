import nimibook / [types, render, tocs, publishers, defaults, docs, books]
export types, render, tocs, publishers, defaults, docs, books

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

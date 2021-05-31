import nimibook / [types, render, tocs, publishers, defaults]
export types, render, tocs, publishers, defaults

template nbUseNimibook* =
  nbDoc.useNimibook

template nbBookTasks* =
  when defined(printToc):
    import print
    print toc
  elif defined(dumpToc):
    dump toc
  elif defined(cleanToc):
    clean toc
  else:
    publish toc

import nimibook / types
import os

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

proc add(toc: var Toc, entry: Entry) =
  toc.entries.add entry

template newToc*(name: string, folder: string, body: untyped): Toc =
  # todo: check folder exists (and is a folder)
  var toc = Toc(title: name, path: folder)
  var levels: seq[int] = @[1]
  var currFolder = folder
  var parentFolder = "."
  template entry(label: string, file: string) =
    # todo: check folder + file is an existing file
    toc.add Entry(title: label, path: joinPath(currFolder, file), levels: levels, isNumbered: true)
    inc levels
  template entry(label: string, file: string, sectionBody: untyped) =
    # todo: check folder + file is an existing file
    toc.add Entry(title: label, path: joinPath(currFolder, file), levels: levels, isNumbered: true)
    parentFolder = currFolder
    currFolder = joinPath(currFolder, file).splitfile.dir
    levels.add 1
    sectionBody
    discard pop levels
    inc levels
    currFolder = parentFolder
  template draft(label: string, file: string) =
    # todo: check folder + file is an existing file
    toc.add Entry(title: label, path: joinPath(currFolder, file), levels: @[], isNumbered: false)
  body
  toc
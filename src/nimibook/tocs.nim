import std / [os, strformat, macros]
import nimibook / [types, paths, entries]
export os.splitFile, os.normalizedPath, paths.formatFileName, paths.joinPath

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

proc add*(book: var Book, entry: Entry) =
  echo book.render entry
  book.toc.entries.add entry

template withToc*(book: var Book, body: untyped) =
  var levels: seq[int] = @[1]
  var folders: seq[string] = @[]
  echo "[nimibook] Table of contents: "

  template entry(label, rfile: string, numbered = true) =
    let inputs = rfile.splitFile
    let file = inputs.dir / formatFileName(inputs)
    book.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: numbered)
    if numbered:
      inc levels

  template draft(label: string, numbered = true) =
    book.add Entry(title: label, path: "", levels: levels, isNumbered: numbered, isDraft: true)
    if numbered:
      inc levels

  template section(label, rfile: string, sectionBody: untyped) =
    let inputs = rfile.splitFile
    let curfolder = inputs.dir
    let file = formatFileName(inputs)
    folders.add curfolder
    book.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: true)
    levels.add 1
    sectionBody
    discard pop levels
    discard pop folders
    inc levels

  body

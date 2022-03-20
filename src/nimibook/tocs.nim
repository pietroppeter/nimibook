import std / [os, strformat, macros]
import nimibook / [types, paths]

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

proc add(toc: var Toc, entry: Entry) =
  let fullPath = entry.path
  # debugEcho "[nimibook.debug] toc.add Entry w fullPath: ", fullPath
  if not entry.isDraft and not fileExists(fullPath):
    echo fmt"[nimibook.warning] Toc entry {fullpath} doesn't exist."
  toc.entries.add entry

template initToc*(body: untyped): Toc =
  var toc: Toc
  var levels: seq[int] = @[1]
  var folders: seq[string] = @[]

  template entry(label, rfile: string, numbered = true) =
    let inputs = rfile.splitFile
    let file = inputs.dir / formatFileName(inputs)
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: numbered)
    if numbered:
      inc levels

  template draft(label, numbered = true) =
    toc.add Entry(title: label, path: "", levels: levels, isNumbered: numbered, isDraft: true)
    if numbered:
      inc levels

  template section(label, rfile: string, sectionBody: untyped) =
    let inputs = rfile.splitFile
    let curfolder = inputs.dir
    let file = formatFileName(inputs)
    folders.add curfolder
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: true)
    levels.add 1
    sectionBody
    discard pop levels
    discard pop folders
    inc levels

  body
  toc
import nimibook / [types, entries]
import std / [os, strutils, strformat]
import jsony

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

proc add(toc: var Toc, entry: Entry) =
  let fullPath = entry.path
  if not fileExists(fullPath):
    raise newException(IOError, fmt"Error entry {fullpath} doesn't exist.")
  toc.entries.add entry

proc joinPath(parts: seq[string], tail: string) : string =
  var parts = parts
  parts.add tail
  normalizedPath(joinPath(parts))

proc formatFileName(inputs: tuple[dir: string, name: string, ext: string]) : string =
  result = inputs.name
  if inputs.ext.isEmptyOrWhitespace():
    result &= ".nim"
  else:
    result &= inputs.ext

template newToc*(booklabel: string, rootfolder: string, body: untyped): Toc =
  var toc = Toc(title: booklabel, path: rootfolder)
  var levels: seq[int] = @[1]
  var folders : seq[string] = @[rootfolder]

  template entry(label, rfile: string) =
    # debugEcho "==> entry <=="
    # debugEcho "    file>", rfile
    let inputs = rfile.splitFile
    let file = inputs.dir / formatFileName(inputs)
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: true)
    inc levels

  template section(label, rfile: string, sectionBody: untyped) =
    let inputs = rfile.splitFile
    let curfolder = inputs.dir
    let file = formatFileName(inputs)
    folders.add curfolder
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: true)
    # debugEcho "==> section <=="
    # debugEcho "    file>", file
    # debugEcho "    folders>", folders
    levels.add 1
    sectionBody
    discard pop levels
    discard pop folders
    inc levels

  template draft(label: string, rfile: string) =
    let inputs = joinPath(rootfolder, rfile).normalizedPath().splitFile()
    let file = formatFileName(inputs)
    toc.add Entry(title: label, path: joinPath(inputs.dir, file), levels: @[], isNumbered: false)
  body
  toc

proc dump*(toc: Toc) =
  let uri = normalizedPath(toc.path / "toc.json")
  writeFile(uri, toc.toJson)

proc clean*(toc: Toc) =
  let uri = normalizedPath(toc.path / "toc.json")
  removeFile(uri)

proc load*(path: string): Toc =
  let uri = normalizedPath(path)
  readFile(uri).fromJson(Toc)

proc check*(toc: Toc) =
  for entry in toc.entries:
    entry.check()
  echo "Check toc => OK"

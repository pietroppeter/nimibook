import std / [os, strutils, strformat]
import jsony
import nimibook / [types, entries]

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

proc add(toc: var Toc, entry: Entry) =
  let fullPath = entry.path
  # debugEcho "==> toc.add Entry <==\n    fullPath>", fullPath
  if not fileExists(fullPath):
    raise newException(IOError, fmt"Error entry {fullpath} doesn't exist.")
  toc.entries.add entry

proc joinPath(parts: seq[string], tail: string): string =
  var parts = parts
  parts.add tail
  normalizedPath(joinPath(parts))

proc formatFileName(inputs: tuple[dir: string, name: string, ext: string]): string =
  result = inputs.name
  if inputs.ext.isEmptyOrWhitespace():
    result &= ".nim"
  else:
    result &= inputs.ext

template newBookFromToc*(booklabel: string, rootfolder: string, body: untyped): Book =
  var book = Book(book_title: booklabel)

  var toc = Toc(path: rootfolder)
  var levels: seq[int] = @[1]
  var folders: seq[string] = @[rootfolder]

  template entry(label, rfile: string, numbered=true) =
    # debugEcho "==> entry <=="
    # debugEcho "    file>", rfile
    let inputs = rfile.splitFile
    let file = inputs.dir / formatFileName(inputs)
    # debugEcho "    inputs>", inputs
    # debugEcho "    file>", file
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: numbered)
    if numbered:
      inc levels

  template draft(label, rfile: string) = entry(label, rfile, numbered=false)

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

  body
  book.toc = toc
  book

proc dump*(book: Book) =
  let uri = normalizedPath(book.toc.path / "book.json")
  writeFile(uri, book.toJson)

proc clean*(book: Book) =
  let uri = normalizedPath(book.toc.path / "book.json")
  removeFile(uri)

proc load*(path: string): Book =
  let uri = normalizedPath(path)
  readFile(uri).fromJson(Book)

proc check*(book: Book) =
  for entry in book.toc.entries:
    entry.check()
  echo "Check toc => OK"

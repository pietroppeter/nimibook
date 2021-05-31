import std / [os, strformat]
import nimibook / [types, defaults, paths]

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

proc add(toc: var Toc, entry: Entry) =
  let fullPath = entry.path
  # debugEcho "==> toc.add Entry <==\n    fullPath>", fullPath
  if not fileExists(fullPath):
    raise newException(IOError, fmt"Error entry {fullpath} doesn't exist.")
  toc.entries.add entry

template newBookFromToc*(booklabel: string, rootfolder: string, body: untyped): Book =
  var book = Book(book_title: booklabel)
  book.setDefaults

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
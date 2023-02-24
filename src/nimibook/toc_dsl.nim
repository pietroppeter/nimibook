import std / [os, macros]
import nimibook / [types, paths, entries]
export os.splitFile, os.normalizedPath, paths.formatFileName, paths.joinPath

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

template initToc*(body: untyped): Toc =
  var toc {.inject.}: Toc
  var levels {.inject.}: seq[int] = @[1]
  var folders {.inject.}: seq[string] = @[]

  body
  toc

template entry*(label, rfile: string, numbered = true) =
  let inputs = rfile.splitFile
  let file = inputs.dir / formatFileName(inputs)
  toc.entries.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: numbered)
  if numbered:
    inc levels

template draft*(label: string, numbered = true) =
  toc.entries.add Entry(title: label, path: "", levels: levels, isNumbered: numbered, isDraft: true)
  if numbered:
    inc levels

template section*(label, rfile: string, sectionBody: untyped) =
  let inputs = rfile.splitFile
  let curfolder = inputs.dir
  let file = formatFileName(inputs)
  folders.add curfolder
  toc.entries.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: true)
  levels.add 1
  sectionBody
  discard pop levels
  discard pop folders
  inc levels

proc showToc*(book: Book): string =
  result.add "S O == Table Of Contents ==  (S: Source, O: Output)\n"
  for e in book.toc.entries:
    result.add book.renderLine(e) & "\n"
  result.add "    == " & $(book.toc.entries.len) &  " entries =="
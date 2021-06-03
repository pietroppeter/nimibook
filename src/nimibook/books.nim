import std / [os, strutils, sequtils, sugar]
import nimibook / [types, entries, tocs]
import jsony

# fix for jsony: quote in string. https://github.com/treeform/jsony/issues/14
proc dumpHook*(s: var string, v: string) =
  when nimvm:
    s.add '"'
    for c in v:
      case c:
      of '\\': s.add r"\\"
      of '\b': s.add r"\b"
      of '\f': s.add r"\f"
      of '\n': s.add r"\n"
      of '\r': s.add r"\r"
      of '\t': s.add r"\t"
      of '"': s.add r"\"""
      else:
        s.add c
    s.add '"'
  else:
    # Its faster to grow the string only once.
    # Then fill the string with pointers.
    # Then cap it off to right length.
    var at = s.len
    s.setLen(s.len + v.len*2+2)

    var ss = cast[ptr UncheckedArray[char]](s[0].addr)
    template add(ss: ptr UncheckedArray[char], c: char) =
      ss[at] = c
      inc at
    template add(ss: ptr UncheckedArray[char], c1, c2: char) =
      ss[at] = c1
      inc at
      ss[at] = c2
      inc at

    ss.add '"'
    for c in v:
      case c:
      of '\\': ss.add '\\', '\\'
      of '\b': ss.add '\\', 'b'
      of '\f': ss.add '\\', 'f'
      of '\n': ss.add '\\', 'n'
      of '\r': ss.add '\\', 'r'
      of '\t': ss.add '\\', 't'
      of '"': ss.add '\\', '"'
      else:
        ss.add c
    ss.add '"'
    s.setLen(at)

proc dump*(book: Book) =
  var book = book
  let uri = normalizedPath(book.toc.path / "book.json")
  writeFile(uri, book.toJson)

proc cleanjson*(book: Book) =
  let uri = normalizedPath(book.toc.path / "book.json")
  removeFile(uri)

proc files(book: Book) : seq[string] =
  result = collect(newSeq):
    for p in book.toc.entries: p.path

proc htmlFiles(book: Book) : seq[string] =
  result = book.toc.entries.map(x => "docs" / url(x))

proc cleanRootFolder(book: Book) =
  # All source files
  let srcurls : seq[string] = book.files
  # debugEcho("walkDirRec ", book.toc.path)
  for f in walkDirRec(book.toc.path):
    let ext = f.splitFile().ext
    if f notin srcurls and ext != ".mustache" and ext != ".nims" and ext != ".cfg" and not f.contains(".git"):
      # debugEcho("    >> removeFile ", f)
      removeFile(f)

proc shouldDelete(book: Book, dir, f: string) : bool =
  # Remove anything that's not in "docs/assets" or "docs/statis" (for image and shit like that).
  if isRelativeTo(f, dir / "assets"):
    return false

  if f in book.keep:
    return false

  if f.contains(".git"):
    return false

  for keep in book.keep:
    if isRelativeTo(f, dir / keep):
      return false

  return true

proc cleanDocFolder(book: Book) =
  # Since getCurrentDir() is used it assumes that the binary is called from the rootfolder
  let docDir = "docs"
  # debugEcho("walkDirRec ", docDir)
  for f in walkDirRec(docDir):
    if shouldDelete(book, docDir, f):
      # debugEcho("    >> removeFile ", f)
      removeFile(f)

  for f in walkDirRec(docDir, yieldFilter={pcDir}):
    # Remove leftover folders
    if shouldDelete(book, docDir, f):
      # debugEcho("    >> removeDir", f)
      removeDir(f)

proc clean*(book: Book) =
  cleanjson(book)
  cleanRootFolder(book)
  cleanDocFolder(book)

proc load*(path: string): Book =
  let uri = normalizedPath(path)
  readFile(uri).fromJson(Book)

proc check*(book: Book) =
  for entry in book.toc.entries:
    entry.check()
  echo "Check Book: OK"

proc initBookFile(book: Book) =
  let srcurls = book.files
  for f in srcurls:
    if not fileExists(f):
      let file = open(f, fmWrite)
      file.close()

proc init*(book: Book) =
  populateAssets(book.toc.path, false)
  initBookFile(book)

proc update*(book: Book) =
  populateAssets(book.toc.path, true)
  initBookFile(book)

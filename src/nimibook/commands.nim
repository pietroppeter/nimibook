import std / [os, strutils, sequtils, sugar]
import nimibook / [types, entries, assets]
import jsony

proc dump*(book: Book) =
  var book = book
  let uri = normalizedPath(book.toc.path / "book.json")
  writeFile(uri, book.toJson)

proc cleanjson*(book: Book) =
  let uri = normalizedPath(book.toc.path / "book.json")
  removeFile(uri)

proc files(book: Book): seq[string] =
  result = collect(newSeq):
    for p in book.toc.entries: p.path

proc htmlFiles(book: Book): seq[string] =
  result = book.toc.entries.map(x => "docs" / url(x))

proc cleanRootFolder(book: Book) =
  # All source files
  let srcurls: seq[string] = book.files
  # debugEcho("walkDirRec ", book.toc.path)
  for f in walkDirRec(book.toc.path):
    let ext = f.splitFile().ext
    if f notin srcurls and ext != ".mustache" and ext != ".nims" and ext != ".cfg" and not f.contains(".git"):
      echo "[nimibook] remove file: ", f
      removeFile(f)

proc shouldDelete(book: Book, dir, f: string): bool =
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
      echo "[nimibook] remove file: ", f
      removeFile(f)

  for f in walkDirRec(docDir, yieldFilter = {pcDir}):
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
  if fileExists(uri):
    result = readFile(uri).fromJson(Book)
  else:
    echo "Warning! No book.json was found!"
    result = Book()

proc check*(book: Book) =
  for entry in book.toc.entries:
    entry.check()
  echo "Check Book: OK"

proc initBookFile(book: Book) =
  let srcurls = book.files
  for f in srcurls:
    if not fileExists(f):
      let (dir, _, _) = f.splitFile()
      if not dir.dirExists:
        echo "[nimibook] creating directory ", dir
        createDir(dir)
      let file = open(f, fmWrite)
      echo "[nimibook] creating file ", f
      file.close()

proc addConfig() =
  const cfg = """
[nimib]
srcDir = "book"
homeDir = "docs"
"""
  if not fileExists("nimib.toml"):
    echo "[nimibook] adding nimib.toml"
    writeFile("nimib.toml", cfg)

proc init*(book: Book) =
  addConfig()
  populateAssets(book.toc.path, false)
  initBookFile(book)

proc update*(book: Book) =
  populateAssets(book.toc.path, true)
  initBookFile(book)

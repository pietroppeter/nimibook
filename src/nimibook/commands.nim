import std / [os, strutils, sugar]
import nimibook / [types, entries, assets, configs]
import jsony

proc dump*(book: Book) =
  var book = book
  let uri = normalizedPath(book.homeDir.string / "book.json")
  echo "[nimibook] dumping ", uri
  writeFile(uri, book.toJson)

proc cleanjson*(book: Book) =
  let uri = normalizedPath(book.homeDir.string / "book.json")
  removeFile(uri)

proc getSrcUrls*(book: Book): seq[string] =
  result = collect(newSeq):
    for e in book.toc.entries:
      normalizedPath(book.srcDir.string / e.path)

proc cleanRootFolder(book: Book) =
  # All source files
  let srcUrls: seq[string] = book.getSrcUrls
  # debugEcho("walkDirRec ", book.toc.path)
  for f in walkDirRec(book.srcDir.string):
    let ext = f.splitFile().ext
    if f notin srcUrls and ext != ".mustache" and ext != ".nims" and ext != ".cfg" and not f.contains(".git"):
      echo "[nimibook] remove file: ", f
      removeFile(f)

proc shouldDelete(book: Book, dir, f: string): bool =
  # Remove anything that's not in "docs/assets" or it is in keep (as a file or inside a keep folder)
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
  let docDir = book.homeDir.string
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
  var errors = 0
  for entry in book.toc.entries:
    if not entry.check(book.homeDir.string):
      echo "[nimibook.error] build output not found: ", entry.url
      inc errors
  if errors > 0:
    echo "[nimibook.error] could not find ", errors, " build outputs"
    quit(1)
  echo "[nimibook] check book: OK"

proc initBookSrc*(book: Book) =
  let srcUrls = book.getSrcUrls
  for f in srcUrls:
    if not fileExists(f):
      let (dir, _, _) = f.splitFile()
      if not dir.dirExists:
        echo "[nimibook] creating directory ", dir
        createDir(dir)
      let file = open(f, fmWrite)
      echo "[nimibook] creating file ", f
      file.close()
    else:
      echo "[nimibook] entry already exists: ", f

proc addConfig(book: Book) =
  let cfg = book.renderConfig()
  if not fileExists("nimib.toml"):
    echo "[nimibook] adding nimib.toml"
    writeFile("nimib.toml", cfg)
    

proc init*(book: Book) =
  addConfig(book)
  populateAssets(book.homeDir.string, false)
  initBookSrc(book)

proc update*(book: Book) =
  populateAssets(book.homeDir.string, true)
  initBookSrc(book)

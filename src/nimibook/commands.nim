import std / [os, strutils, sugar]
import nimibook / [types, entries, assets, configs]
import jsony

proc dump*(book: Book) =
  var book = book
  let uri = normalizedPath(book.homeDir / "book.json")
  echo "[nimibook] dumping ", uri
  writeFile(uri, book.toJson)

proc load*(path: string): Book =
  let uri = normalizedPath(path)
  if fileExists(uri):
    result = readFile(uri).fromJson(Book)
  else:
    echo "[nimibook.warning] No book json was found: ", uri
    result = Book()

proc getSrcUrls*(book: Book): seq[string] =
  result = collect(newSeq):
    for e in book.toc.entries:
      normalizedPath(book.srcDir / e.path)

proc cleanJson*(book: Book) =
  let uri = normalizedPath(book.homeDir / "book.json")
  echo "[nimibook] remove file: ", uri
  removeFile(uri)

proc cleanSrcFolder(book: Book) =
  let srcUrls: seq[string] = book.getSrcUrls
  for f in walkDirRec(book.srcDir):
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

proc cleanOutFolder(book: Book) =
  let outDir = book.homeDir
  for f in walkDirRec(outDir):
    if shouldDelete(book, outDir, f):
      echo "[nimibook] remove file: ", f
      removeFile(f)

  for d in walkDirRec(outDir, yieldFilter = {pcDir}):
    # Remove leftover folders
    if shouldDelete(book, outDir, d):
      echo "[nimibook] remove dir: ", d
      removeDir(d)

proc clean*(book: Book) =
  cleanJson(book)
  cleanSrcFolder(book)
  cleanOutFolder(book)

proc check*(book: Book) =
  var
    srcErrors = 0
    outErrors = 0
  for entry in book.toc.entries:
    if entry.isDraft:
      continue
    if not (book.hasSrc entry):
      inc srcErrors
      continue
    if not book.hasOut entry:
      inc outErrors
  if srcErrors + outErrors > 0:
    echo "[nimibook.error] could not find ", srcErrors, " sources, and ", outErrors, " build outputs"
    quit(1)
  echo "[nimibook] check book: OK"

proc addConfig(book: Book) =
  let cfg = book.renderConfig()
  if not fileExists("nimib.toml"):
    echo "[nimibook] adding nimib.toml"
    writeFile("nimib.toml", cfg)

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

proc init*(book: Book) =
  addConfig(book)
  populateAssets(book.homeDir, force = false)
  initBookSrc(book)

proc update*(book: Book) =
  populateAssets(book.homeDir, force = true)
  initBookSrc(book)

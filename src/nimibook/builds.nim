import std / [os, strutils]
import nimibook / [types, commands, themes]
import nimib

proc buildNim*(entry: Entry, srcDir: string, nimOptions: seq[string]): bool =
  let
    cmd = "nim"
    args = @["r"] & nimOptions & @[srcDir / entry.path]
  # "-d:release", "-f", "--verbosity:0", "--hints:off"
  debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    echo "[nimibook.error] error while processing ", entry.path
    return false
  return true

proc buildMd*(entry: Entry): bool =
  try:
    nbInit(theme = useNimibook, thisFileRel = entry.path)
    nbText nb.source
    nbSave
    setCurrentDir nb.initDir
    return true
  except:
    echo "[nimibook.error] error while processing ", entry.path
    return false

proc build*(entry: Entry, srcDir: string, nimOptions: seq[string]): bool =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    return buildNim(entry, srcDir, nimOptions)
  elif splitted.ext == ".md":
    return buildMd(entry)
  else:
    echo "[nimibook.error] invalid file extension (must be one of .nim, .md): ", splitted.ext
    return false

proc build*(book: Book, nimOptions: seq[string] = @[]) =
  var buildErrors: seq[string]
  dump book
  for entry in book.toc.entries:
    if entry.isDraft:
      continue
    echo "[nimibook] build entry: ", entry.path
    if not build(entry, book.srcDir, nimOptions):
      buildErrors.add entry.path
  if len(buildErrors) > 0:
    echo "[nimibook.error] ", len(buildErrors), " build errors:"
    for err in buildErrors:
      echo "  ❌ ", err
    quit(1)
  check book

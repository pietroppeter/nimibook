import std / [os, strutils, asyncdispatch, osproc, streams]
import nimibook / [types, commands, themes]
import nimib

proc buildNim*(entry: Entry, srcDir: string, nimOptions: seq[string]): Future[bool] {.async.} =
  let
    cmd = "nim"
    args = @["r"] & nimOptions & @[srcDir / entry.path]
  # "-d:release", "-f", "--verbosity:0", "--hints:off"
  debugEcho "[Executing] ", cmd, " ", args.join(" ")

  let process = startProcess(cmd, args = args, options = {poUsePath, poStdErrToStdOut})
  defer: process.close()
  while process.running():
    await sleepAsync(10)

  result = process.peekexitCode == 0
  if not result:
    # Process failed so we write a '.log'
    let logPath = entry.path.changeFileExt("log")
    discard tryRemoveFile(logPath)
    let fs = openFileStream(logPath, fmWrite)
    defer: fs.close()
    for line in process.lines:
      fs.writeLine(line)

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

proc build*(entry: Entry, srcDir: string, nimOptions: seq[string]): Future[bool] {.async.} =
  let splitted = entry.path.splitFile()
  case splitted.ext
  of ".nim":
    return await buildNim(entry, srcDir, nimOptions)
  of ".md":
    return buildMd(entry)
  else:
    echo "[nimibook.error] invalid file extension (must be one of .nim, .md): ", splitted.ext
    return false

proc build*(book: Book, nimOptions: seq[string] = @[]) =
  var
    buildPaths: seq[string]
    buildFutures: seq[Future[bool]]
  dump book
  for entry in book.toc.entries:
    if entry.isDraft:
      continue
    echo "[nimibook] build entry: ", entry.path
    buildFutures.add build(entry, book.srcDir, nimOptions)
    buildPaths.add entry.path

  var buildErrors: seq[string]
  while buildFutures.len > 0:
    # 'all' from asyndispatch doesnt return them chronologically.
    # meaning logged errors would not present the right path
    if waitfor buildFutures[^1].withTimeout(300):
      if not buildFutures[^1].read:
        buildErrors.add buildPaths[^1]

      discard buildPaths.pop
      discard buildFutures.pop

  if len(buildErrors) > 0:
    echo "[nimibook.error] ", len(buildErrors), " build errors:"
    for err in buildErrors:
      echo "  ❌ ", err
    quit(1)
  check book

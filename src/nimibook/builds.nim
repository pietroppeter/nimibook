import std / [os, strutils, asyncdispatch, osproc, streams, sugar]
import std/compilesettings
import nimibook / [types, commands, themes]
import nimib

const nimcacheFolder = querySetting(SingleValueSetting.nimcacheDir)

var numberBuildsRunning = 0

proc buildNim*(entry: Entry, srcDir: string, nimOptions: seq[string]): Future[bool] {.async.} =
  let splitEntry = splitFile(entry.path)
  # To avoid collisions of the intermediate C/object files for files with the same name,
  # e.g. index.nim and some_folder/index.nim, we make a separate nimcache folder for each file.
  # This way all files are isolated from each other. In the example the two folders would be
  # nimcache/index/ and nimcache/some_folder/index/
  let cacheFolder = nimcacheFolder / splitEntry.dir / splitEntry.name
  createDir(cacheFolder)
  let
    cmd = "nim"
    args = @["r", "--nimcache:" & cacheFolder] & nimOptions & @[srcDir / entry.path]
  # "-d:release", "-f", "--verbosity:0", "--hints:off"
  debugEcho "[Executing] ", cmd, " ", args.join(" ")

  const nimibMaxProcesses {.intdefine.}: int = 10
  # If more processes than the limit are already running, wait for a free spot.
  while numberBuildsRunning > nimibMaxProcesses:
    await sleepAsync(10)

  # Start a build in a new process
  inc(numberBuildsRunning)
  let process = startProcess(cmd, args = args, options = {poUsePath, poStdErrToStdOut})
  defer: process.close()
  while process.running():
    await sleepAsync(10)

  let logPath = srcDir / entry.path.changeFileExt("log")
  discard tryRemoveFile(logPath)

  result = process.peekexitCode == 0
  if not result:
    # Process failed so we write a '.log'
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
    buildErrors: seq[string]
    buildFutures: seq[Future[bool]]
  dump book
  for i in 0..book.toc.entries.high:
    let entry = book.toc.entries[i] # use index since `items` returns `lent` in `1.7.x+`
    if entry.isDraft:
      continue
    echo "[nimibook] build entry: ", entry.path

    const nimibParallelBuild {.booldefine.}: bool = true

    let fut = build(entry, book.srcDir, nimOptions)
    buildFutures.add fut
    when not nimibParallelBuild:
      # Run the current file before starting the next one
      discard waitFor fut

    closureScope:
      let path = entry.path
      buildFutures[^1].addCallback do (f: Future[bool]):
        dec(numberBuildsRunning)
        if not f.read():
          buildErrors.add path

  discard waitFor all buildFutures

  if len(buildErrors) > 0:
    echo "[nimibook.error] ", len(buildErrors), " build errors:"
    for err in buildErrors:
      echo "\n#########################\n"
      echo "  ❌ ", err
      let errorLog = readFile(book.srcDir / err.changeFileExt("log"))
      echo errorLog
    quit(1)
  check book

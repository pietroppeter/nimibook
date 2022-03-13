import std / [os, strutils]
import nimibook / [types, commands, themes]
import nimib

proc buildNim*(entry: Entry) =
  let
    cmd = "nim"
    args = ["r", "-d:release", "-f", "--verbosity:0", "--hints:off", entry.path]
  debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc buildMd*(entry: Entry) =
  nbInit(theme = useNimibook, thisFileRel = ".." / entry.path) # entry path contains srcDir (why? should fix that!)
  nbText nb.source
  nbSave
  setCurrentDir nb.initDir

proc build*(entry: Entry) =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    buildNim(entry)
  elif splitted.ext == ".md":
    buildMd(entry)
  else:
    raise newException(IOError, "Error invalid file extension.")

proc build*(book: Book) =
  dump book
  for entry in book.toc.entries:
    echo "[nimibook] build entry: ", entry.path
    build entry
  check book

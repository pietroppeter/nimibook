import std / [os, strutils]
import nimibook / [types, commands, theme]
import nimib

proc nimPublish*(entry: Entry) =
  let
    cmd = "nim"
    args = ["r", "-d:release", "-f", "--verbosity:0", "--hints:off", entry.path]
  debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc mdPublish*(entry: Entry) =
  nbInit(theme = useNimibook, thisFileRel = ".." / entry.path) # entry path contains srcDir (why? should fix that!)
  nbText nb.source
  nbSave
  setCurrentDir nb.initDir

proc publish*(entry: Entry) =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    nimPublish(entry)
  elif splitted.ext == ".md":
    mdPublish(entry)
  else:
    raise newException(IOError, "Error invalid file extension.")

proc publish*(book: Book) =
  dump book
  for entry in book.toc.entries:
    echo "[nimibook] publish entry: ", entry.path
    entry.publish()
  cleanjson book
  check book

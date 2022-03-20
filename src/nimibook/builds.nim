import std / [os, strutils]
import nimibook / [types, commands, themes]
import nimib

proc buildNim*(entry: Entry, srcDir: string) =
  let
    cmd = "nim"
    args = ["r", srcDir / entry.path]
  # "-d:release", "-f", "--verbosity:0", "--hints:off"
  debugEcho "[debug] commandLineParams: ", commandLineParams() # remove this line at the end
  debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc buildMd*(entry: Entry) =
  nbInit(theme = useNimibook, thisFileRel = entry.path)
  nbText nb.source
  nbSave
  setCurrentDir nb.initDir

proc build*(entry: Entry, srcDir: string) =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    buildNim(entry, srcDir)
  elif splitted.ext == ".md":
    buildMd(entry)
  else:
    raise newException(IOError, "Error invalid file extension.")

proc build*(book: Book) =
  dump book
  for entry in book.toc.entries:
    echo "[nimibook] build entry: ", entry.path
    build(entry, book.srcDir.string)
  check book

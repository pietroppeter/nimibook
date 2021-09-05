import std / [os, strutils, strformat]
import nimibook / [types, books, docs]
import nimib

proc nimPublish*(entry: Entry) =
  let
    cmd = "nim"
    # Apparently when used as a binary this generate a process in another shell
    # Which means env variable are not going to be available
    # So here's a little trick to propagate the info
    # See comment in docs.nim useNimibook() proc
    nimibSrcDir = getEnv("nimibSrcDir")
    nimibHomeDir = nimibSrcDir.parentDir() / "docs"
    args = ["r", "-d:release", "-f", &"-d:nimibSrcDir={nimibSrcDir}", &"-d:nimibHomeDir={nimibHomeDir}", "--verbosity:0", "--hints:off", entry.path]
  debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc mdPublish*(entry: Entry) =
  nbInit
  nbDoc.filename = (nb.thisDir / ("../../" & entry.path).RelativeDir).string
  nbDoc.useNimibook
  nbText entry.path.readFile
  nbSave

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

import std / [os, strutils]
import nimibook / [types, books, docs]
import nimib

proc nimPublish*(entry: Entry) =
  let
    cmd = "nim"
    args = ["r", "-d:release", "-f", entry.path]
  debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc mdPublish*(entry: Entry) =
  nbInit
  nbDoc.filename = (nbThisDir / ("../../" & entry.path).RelativeDir).string
  nbDoc.useNimibook
  withDir(nbHomeDir / "..".RelativeDir):
    nbText entry.path.readFile
  nbSave
  setCurrentDir nbInitDir # reset current directory

proc publish*(entry: Entry) =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    nimPublish(entry)
  elif splitted.ext == ".md":
    mdPublish(entry)
  else:
    raise newException(IOError, "Error invalid file extension.")

proc publish*(book: Book) =
  for entry in book.toc.entries:
    entry.publish()
  clean book
  check book

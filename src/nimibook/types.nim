import std/strutils
import std/strformat
import std/os

type
  Entry* = object
    title*: string
    path*: string
    levels*: seq[int]
    isNumbered*: bool
    isActive*: bool
  Toc* = object
    title*: string
    path*: string
    entries*: seq[Entry]

proc nimOutput*(entry: Entry, rootfolder: string) =
  let
    cmd = "nim"
    args = ["r", "-d:release", "-d:nimibCustomPostInit", joinPath(rootfolder, entry.path)]
  # debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc mdOutput*(entry: Entry, rootfolder: string) =
  raise newException(IOError, "Markdown not yet supported. We advise listening to elevators music while we are working on this feature.")

proc output*(entry: Entry, rootfolder: string) =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    nimOutput(entry, rootfolder)
  elif splitted.ext == ".md":
    mdOutput(entry, rootfolder)
  else:
    raise newException(IOError, "Error invalid file extension.")

proc url*(e: Entry): string =
  var path = normalizedPath(e.path)
  when defined(windows):
    path.changeFileExt("html").replace('\\', '/')
  else:
    path.changeFileExt("html")


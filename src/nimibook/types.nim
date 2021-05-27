import std/[strutils, strformat]
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

proc nimPublish*(entry: Entry) =
  let
    cmd = "nim"
    args = ["r", "-d:release", "-d:nimibCustomPostInit", entry.path]
  # debugEcho "[Executing] ", cmd, " ", args.join(" ")
  if execShellCmd(cmd & " " & args.join(" ")) != 0:
    quit(1)

proc mdPublish*(entry: Entry) =
  raise newException(IOError, "Markdown not yet supported. We advise listening to elevators music while we are working on this feature.")

proc publish*(entry: Entry) =
  let splitted = entry.path.splitFile()
  if splitted.ext == ".nim":
    nimPublish(entry)
  elif splitted.ext == ".md":
    mdPublish(entry)
  else:
    raise newException(IOError, "Error invalid file extension.")

proc url*(e: Entry): string =
  var path = changeFileExt(e.path, "html").tailDir()
  when defined(windows):
    path.replace('\\', '/')
  else:
    path

proc check*(e: Entry) =
  let entryurl = url(e)
  if not fileExists("docs" / entryurl):
    raise newException(IOError, fmt"Error finding {entryurl} : no such file or directory")

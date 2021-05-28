import nimibook / types
import std / [os, strutils, strformat]

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

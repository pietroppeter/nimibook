import std / [os, strformat]
import nimibook / types

proc url*(e: Entry): string =
  var path = changeFileExt(e.path, "html").tailDir()
  when defined(windows):
    path.replace('\\', '/')
  else:
    path

proc check*(e: Entry) =
  let entryurl = "docs" / url(e)
  if not fileExists(entryurl):
    raise newException(IOError, fmt"Error finding {entryurl} : no such file or directory")

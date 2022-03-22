import std / [os, strformat, strutils]
import nimibook / types

proc number*(e: Entry): string =
  if e.isNumbered:
    for i in e.levels:
      result.add $i
      result.add "."

proc url*(e: Entry): string =
  var path = changeFileExt(e.path, "html")
  when defined(windows):
    path.replace('\\', '/')
  else:
    path

proc render*(book: Book, e: Entry): string =
  result.add "  ".repeat(e.levels.len) & e.number
  if e.isNumbered:
    result.add " "
  result.add fmt"[{e.title}]({e.path})"

proc check*(e: Entry, homeDir: string): bool =
  let entryurl = homeDir / url(e)
  if e.isDraft:
    return true
  # debugEcho "[nimibook.debug] ", entryurl
  if not fileExists(entryurl):
    return false
  return true
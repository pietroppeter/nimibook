when defined(windows):
  import strutils
import os

type
  Entry* = object
    title*: string
    path*: string
    levels*: seq[int]
    isNumbered*: bool
  Toc* = object
    title*: string
    path*: string    
    entries*: seq[Entry]

proc url*(e: Entry): string = 
  when defined(windows):
    e.path.changeFileExt("html").replace('\\', '/')
  else:
    e.path.changeFileExt("html")
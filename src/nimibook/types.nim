when defined(windows):
  import strutils
import os

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

proc url*(e: Entry): string =
  normalizedPath(e.path).changeFileExt("html")


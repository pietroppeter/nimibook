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

proc srcPath*(book: Book, e: Entry): string =
  normalizedPath(book.srcDir / e.path)

proc outPath*(book: Book, e: Entry): string =
  normalizedPath(book.homeDir / e.url)

proc hasSrc*(book: Book, e: Entry): bool =
  fileExists(book.srcPath e)

proc hasOut*(book: Book, e: Entry): bool =
  fileExists(book.outPath e)

proc renderLine*(book: Book, e: Entry): string =
  # hasSrc
  if e.isDraft:
    result.add "❔"
  elif book.hasSrc e:
    result.add "✅"
  else:
    result.add "❌"
  # hasOut
  if e.isDraft:
    result.add " "
  elif book.hasOut e:
    result.add "✅"
  else:
    result.add "❌"
  result.add "  ".repeat(e.levels.len) & e.number
  if e.isNumbered:
    result.add " "
  result.add fmt"[{e.title}]({e.path})"

proc nextEntryUrl*(book: Book, i: int): string =
  var j = i + 1
  while j >= 0 and j < book.toc.entries.high and book.toc.entries[j].isDraft:
    inc j
  if j >= 0 and j <= book.toc.entries.high:
    result = book.toc.entries[j].url

proc prevEntryUrl*(book: Book, i: int): string =
  var j = i - 1
  while j >= 0 and j < book.toc.entries.high and book.toc.entries[j].isDraft:
    dec j
  if j >= 0 and j < book.toc.entries.high:
    result = book.toc.entries[j].url

import os
import strformat
import algorithm

type
  Entry = object
    title: string
    path: string
    levels: seq[int]
    isNumbered: bool
#############################################################################
## This section is only useful to create a seq of Entries from books files ##
## After consideration, it is easier to have an API to construct entries   ##
#############################################################################
# var entries : seq[Entry]
# var excludedFile: seq[string]
#
# proc makeChapter(title, name: string, levels: varargs[int]) =
#   entries.add Entry(title: title, path: name, levels: @levels)
#
# proc makeSection(title, name: string, levels: varargs[int]) =
#   entries.add Entry(title: title, path: name, levels: @levels)
#
# proc hasContent(folder: string): bool =
#   for kind, path in walkdir(folder):
#     if kind == pcFile:
#       let (dir, name, ext) = path.splitfile()
#       # TODO fix this
#       if ext == ".nim" and name in ["index", "contributors"]:
#         debugEcho &"    hasContent=> {folder}, {path} => True"
#         return true
#   return false
#
# proc populateEntries(rootdir: string, levels: varargs[int], addIndex: bool = true) =
#   once:
#     makeChapter(rootdir, "index", 1)
#
#   debugEcho "=> populateEntries : ", rootdir
#   var levels : seq[int] = @levels
#   if addIndex:
#     levels.add 1
#
#   for kind, path in walkDir(rootdir):
#     var (dir, name, ext) = path.splitfile()
#     if kind == pcFile:
#       # Add file as incremented numbers
#       if ext == ".nim" and name notin ["index"] and path notin excludedFile:
#         makeChapter(name, dir/name, levels)
#         inc(levels[^1])
#
#     elif kind == pcDir:
#       debugEcho "  ", kind, " => path=", path
#       if hasContent(path):
#         inc(levels[^1])
#         if fileExists(path/"index.nim"):
#           debugEcho &"    Found index.nim... => ({dir}, {name}, {ext})"
#           makeSection(name, path/"index", levels)
#         else:
#           var counter = 0
#           for f in walkFiles(path/"*.nim"):
#             doAssert(counter == 0, "Error folder that do not contain index.nim can only contains a single Nim file")
#             let (dir, name, ext) = f.splitfile()
#             debugEcho &"    Walking files... => {f} => ({dir}, {name}, {ext})"
#             makeSection(name, dir/name, levels)
#             excludedFile.add f
#             inc(counter)
#         populateEntries(path, levels, true)
#       else:
#         populateEntries(path, levels, false)
####################
## End of section ##
####################

const path_to_root = "{{path_to_root}}"

proc closeSection() : string =
  # First chapter has no opened section so close should do nothing
  # once:
  #   return ""

  result.add """
  </ol>
  </li>
"""

proc openSection() : string =
  result.add """
  <li>
  <ol class="section">
"""

proc addEntryImpl(e: Entry) : string =
  debugEcho &"    makeChapter => {e.title} : {e.path} => {e.levels}"
  if e.isNumbered:
    var chapNumber  : string
    for i in e.levels:
      chapNumber.add $i
      chapNumber.add "."

    result.add &"""
  <li class="chapter-item expanded ">
    <a href="{path_to_root}{e.path}.html" tabindex="0">
      <strong aria-hidden="true">{chapNumber}</strong> {e.title}
    </a>
  </li>
"""
  else:
    result.add &"""
  <li class="chapter-item expanded ">
    <a href="{path_to_root}{e.path}.html" tabindex="0">
      {e.title}
    </a>
  </li>
"""

proc openGenToc() : string =
  result.add """
<ol class="chapter">
"""

proc closeGenToc() : string =
  # Close last opened section that will not be closed anywhere
  # result.add closeSection()
  result.add """
</ol>
"""

proc intcmp(x, y: int): int =
  if x < y:
    return -1
  elif x == y:
    return 0
  else:
    return 1

proc mycmp(x, y: seq[int]): int =
  var idx = 0
  var r = intcmp(x[idx], y[idx])
  while r == 0:
    inc(idx)
    if idx >= x.len() and idx < y.len():
      return -1
    if idx >= y.len() and idx < x.len():
      return 1
    else:
      r = intcmp(x[idx], y[idx])
  return r

proc entrycmp(x, y: Entry): int=
  let r = mycmp(x.levels, y.levels)
  doAssert(r != 0, "Entry cannot be equal")
  return r

proc write_gentoc(entries: seq[Entry], filename: string) =
  var r: string
  r.add openGenToc()

  var sortedentries = entries.sorted(entrycmp)
  echo sortedentries
  var previousLevel = 1
  for e in sortedentries:
    if len(e.levels) == previousLevel:
      discard
    elif len(e.levels) > previousLevel:
      r.add openSection()
    else:
      r.add closeSection()

    echo "    ", e.title, " ==> ", e.path
    r.add addEntryImpl(e)
    previousLevel = len(e.levels)

  r.add closeGenToc()
  let f = open(filename, fmWrite)
  defer: f.close()
  f.write(r)

when isMainModule:
  var entries = @[Entry(title: "Introduction", path: "index", levels: @[1], isNumbered: true),
                  Entry(title: "Basics", path: "basics/index", levels: @[2], isNumbered: true),
                  Entry(title: "Models", path: "basics/models", levels: @[2, 2], isNumbered: true),
                  Entry(title: "Data Manipulation", path: "basics/data_manipulation", levels: @[2, 1], isNumbered: true),
                  Entry(title: "Plotting", path: "basics/plotting", levels: @[2, 1, 1], isNumbered: false),
                  Entry(title: "Contributors", path: "misc/but/very/far/contributors", levels: @[3], isNumbered: true)
                  ]
  write_gentoc(entries, "books/toc.mustache")
  copyFile("books/toc.mustache", "tocgen.mustache.html")


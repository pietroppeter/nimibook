import os
import strformat
import algorithm

type
  Entry = object
    title: string
    path: string
    levels: seq[int]
    isSection: bool
#############################################################################
## This section is only useful to create a seq of Entries from books files ##
## After consideration, it is easier to have an API to construct entries   ##
#############################################################################
# var entries : seq[Entry]
# var excludedFile: seq[string]
#
# proc makeChapter(title, name: string, levels: varargs[int]) =
#   entries.add Entry(title: title, path: name, levels: @levels, isSection: false)
#
# proc makeSection(title, name: string, levels: varargs[int]) =
#   entries.add Entry(title: title, path: name, levels: @levels, isSection: true)
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

proc makeChapterImpl(title, name: string, levels: varargs[int]) : string =
  debugEcho &"    makeChapter => {title} : {name} => {levels}"
  var chapNumber  : string
  for i in levels:
    chapNumber.add $i
    chapNumber.add "."

  result.add &"""
  <li class="chapter-item expanded ">
    <a href="{path_to_root}{name}.html" tabindex="0">
      <strong aria-hidden="true">{chapNumber}</strong> {title}
    </a>
  </li>
"""

proc makeSectionImpl(title, name: string, levels: varargs[int]) : string =
  # result.add closeSection()
  result.add makeChapterImpl(title, name, levels)
  # result.add openSection()

proc openGenToc(rootdir: string) : string =
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

proc write_gentoc(rootdir, filename: string) =
  var r: string
  r.add openGenToc(rootdir)
  # You can use gentoc to parse rootdir foler and generate an arborescence
  # It might be simpler to just expose an API to construct the seq[Entry]
  # populateEntries(rootdir)

  var entries = @[Entry(title: "Introduction", path: "index", levels: @[1], isSection: true),
                  Entry(title: "Basics", path: "basics/index", levels: @[2], isSection: true),
                  Entry(title: "Models", path: "basics/models", levels: @[2, 2], isSection: false),
                  Entry(title: "Data Manipulation", path: "basics/data_manipulation", levels: @[2, 1], isSection: true),
                  Entry(title: "Plotting", path: "basics/plotting", levels: @[2, 1, 1], isSection: false),
                  Entry(title: "Contributors", path: "misc/but/very/far/contributors", levels: @[3], isSection: true)
                  ]
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
    echo "    ", e.title, " ==> ", e.path, " ==> ", e.isSection
    if e.isSection:
      r.add makeSectionImpl(e.title, e.path, e.levels)
    else:
      r.add makeChapterImpl(e.title, e.path, e.levels)
    previousLevel = len(e.levels)

  r.add closeGenToc()
  # TODO use rootdir / filename
  let f = open(filename, fmWrite)
  defer: f.close()
  f.write(r)

when isMainModule:
  write_gentoc("books", "books/toc.mustache")
  copyFile("books/toc.mustache", "tocgen.mustache.html")


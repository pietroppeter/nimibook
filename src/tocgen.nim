import os
import strformat
import algorithm

const path_to_root = "{{path_to_root}}"
var excludedFile: seq[string]

proc hasContent(folder: string): bool =
  for kind, path in walkdir(folder):
    if kind == pcFile:
      let (dir, name, ext) = path.splitfile()
      # TODO fix this
      if ext == ".nim" and name in ["index", "contributors"]:
        debugEcho &"    hasContent=> {folder}, {path} => True"
        return true
  return false

type
  Entry = object
    title: string
    name: string
    levels: seq[int]
    isSection: bool

var entries : seq[Entry]

proc makeChapter(title, name: string, levels: varargs[int]) : string =
  entries.add Entry(title: title, name: name, levels: @levels, isSection: false)

proc closeSection() : string =
  # First chapter has no opened section so close should do nothing
  once:
    return ""

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
  result.add closeSection()
  result.add makeChapterImpl(title, name, levels)
  result.add openSection()

proc makeSection(title, name: string, levels: varargs[int]) : string =
  entries.add Entry(title: title, name: name, levels: @levels, isSection: true)

proc gentoc(rootdir: string, levels: varargs[int], addIndex: bool = true) : string =
  debugEcho "=> gentoc : ", rootdir
  var levels : seq[int] = @levels
  if addIndex:
    levels.add 1

  for kind, path in walkDir(rootdir):
    var (dir, name, ext) = path.splitfile()
    if kind == pcFile:
      # Add file as incremented numbers
      if ext == ".nim" and name notin ["index"] and path notin excludedFile:
        result.add makeChapter(name, dir/name, levels)
        inc(levels[^1])

    elif kind == pcDir:
      debugEcho "  ", kind, " => path=", path
      if hasContent(path):
        inc(levels[^1])
        if fileExists(path/"index.nim"):
          debugEcho &"    Found index.nim... => ({dir}, {name}, {ext})"
          result.add makeSection(name, path/"index", levels)
        else:
          var counter = 0
          for f in walkFiles(path/"*.nim"):
            doAssert(counter == 0, "Error folder that do not contain index.nim can only contains a single Nim file")
            let (dir, name, ext) = f.splitfile()
            debugEcho &"    Walking files... => {f} => ({dir}, {name}, {ext})"
            result.add makeSection(name, dir/name, levels)
            excludedFile.add f
            inc(counter)
        result.add gentoc(path, levels, true)
      else:
        result.add gentoc(path, levels, false)


proc openGenToc(rootdir: string) : string =
  result.add """
<ol class="chapter">
"""
  result.add makeChapter(rootdir, "index", 1)

proc closeGenToc() : string =
  # Close last opened section that will not be closed anywhere
  result.add closeSection()
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
  discard gentoc(rootdir)

  var entries = @[Entry(title: "Introduction", name: "index", levels: @[1], isSection: false),
                  Entry(title: "Basics", name: "books/basics/index", levels: @[2], isSection: true),
                  Entry(title: "Models", name: "books/basics/models", levels: @[2, 2], isSection: false),
                  Entry(title: "Data Manipulation", name: "books/basics/data_manipulation", levels: @[2, 1], isSection: false),
                  Entry(title: "Plotting", name: "books/basics/plotting", levels: @[2, 3], isSection: false),
                  Entry(title: "Contributors", name: "books/misc/but/very/far/contributors", levels: @[3], isSection: true)
                  ]
  var sortedentries = entries.sorted(entrycmp)
  echo sortedentries
  for e in sortedentries:
    echo "    ", e.title, " ==> ", e.name, " ==> ", e.isSection
    if e.isSection:
      r.add makeSectionImpl(e.title, e.name, e.levels)
    else:
      r.add makeChapterImpl(e.title, e.name, e.levels)

  r.add closeGenToc()
  # TODO use rootdir / filename
  let f = open(filename, fmWrite)
  defer: f.close()
  f.write(r)

when isMainModule:
  # write_gentoc("books", "tocgen.mustache.html")
  write_gentoc("books", "books/toc.mustache")
  copyFile("books/toc.mustache", "tocgen.mustache.html")


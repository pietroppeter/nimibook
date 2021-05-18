import os
import strformat

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

proc makeChapter(title, name: string, levels: varargs[int]) : string =
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
          result.add closeSection()
          result.add makeChapter(name, path/"index", levels)
          result.add openSection()
        else:
          var counter = 0
          for f in walkFiles(path/"*.nim"):
            doAssert(counter == 0, "Error folder that do not contain index.nim can only contains a single Nim file")
            let (dir, name, ext) = f.splitfile()
            debugEcho &"    Walking files... => {f} => ({dir}, {name}, {ext})"
            result.add closeSection()
            result.add makeChapter(name, dir/name, levels)
            result.add openSection()
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

proc write_gentoc(rootdir, filename: string) =
  var r: string
  r.add openGenToc(rootdir)
  r.add gentoc(rootdir)
  r.add closeGenToc()
  # TODO use rootdir / filename
  let f = open(filename, fmWrite)
  defer: f.close()
  f.write(r)

when isMainModule:
  # write_gentoc("books", "tocgen.mustache.html")
  write_gentoc("books", "books/toc.mustache")
  copyFile("books/toc.mustache", "tocgen.mustache.html")


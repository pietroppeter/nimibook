import std / [os, strformat, macros]
import nimibook / [types, defaults, paths]

proc inc(levels: var seq[int]) =
  levels[levels.high] = levels[levels.high] + 1

# TODO comment debugEcho before merge
proc add(toc: var Toc, entry: Entry) =
  let fullPath = entry.path
  # debugEcho "==> toc.add Entry <==\n    fullPath>", fullPath
  if not fileExists(fullPath):
    raise newException(IOError, fmt"Error entry {fullpath} doesn't exist.")
  toc.entries.add entry

template populateAssets*(rootfolder: string, force: bool = false) =
  let
    baseRessources = currentSourcePath().parentDir() / "resources"
    assetsSrc = baseRessources / "assets"
    assetsTarget = getProjectPath() / "docs" / "assets"

    mustacheSrc = baseRessources / "template"
    mustacheTarget = getProjectPath() / rootfolder

  for file in walkFiles(mustacheSrc / "*.mustache"):
    let name = file.splitPath().tail
    # Copy default mustache file
    if not fileExists(mustacheTarget / name):
      # debugEcho "copyFile(", file, ", ", mustacheTarget, ") "
      copyFile(file, mustacheTarget / name)

  if not dirExists(assetsTarget):
    # debugEcho "==> copyDir(", src, ", ", target, ")"
    copyDir(assetsSrc, assetsTarget)
  else:
    if force:
      removeDir(assetsTarget)
      copyDir(assetsSrc, assetsTarget)

template newBookFromToc*(booklabel: string, rootfolder: string, body: untyped): Book =
  populateAssets(rootfolder, false)
  var book = Book(book_title: booklabel)
  book.setDefaults
  book.path_to_root = rootfolder
  putEnv("nimibSrcDir", getCurrentDir() / rootfolder)

  var toc = Toc(path: rootfolder)
  var levels: seq[int] = @[1]
  var folders: seq[string] = @[rootfolder]

  template entry(label, rfile: string, numbered = true) =
    let inputs = rfile.splitFile
    let file = inputs.dir / formatFileName(inputs)
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: numbered)
    if numbered:
      inc levels

  template draft(label, rfile: string) = entry(label, rfile, numbered = false)

  template section(label, rfile: string, sectionBody: untyped) =
    let inputs = rfile.splitFile
    let curfolder = inputs.dir
    let file = formatFileName(inputs)
    folders.add curfolder
    toc.add Entry(title: label, path: joinPath(folders, file).normalizedPath(), levels: levels, isNumbered: true)
    levels.add 1
    sectionBody
    discard pop levels
    discard pop folders
    inc levels

  body
  book.toc = toc
  # Dump json here so we avoid having to use Nimble in use Nimibook
  dump(book)
  book

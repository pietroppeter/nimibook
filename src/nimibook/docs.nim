import std / [strutils, os]
import nimib, nimib / paths
import nimibook / [types, books, entries, render]

proc useNimibook*(nbDoc: var NbDoc) =
  # path handling (fix upstream in nimib)
  let
    nbThisFile = changeFileExt(nbDoc.filename.AbsoluteFile, ".nim")
    thisTuple = nbThisFile.splitFile
    nbThisDir: AbsoluteDir = thisTuple.dir
    nbHomeDir: AbsoluteDir = findNimbleDir(nbThisDir) / "docs".RelativeDir
    nbSrcDir = nbHomeDir / RelativeDir(".." / "book")

  nbDoc.filename = relativeTo(changeFileExt(nbThisFile, ".html"), nbSrcDir).string
  nbDoc.context["path_to_root"] = nbDoc.context["home_path"].castStr & "/" # I probably should make sure to have / at the end
  # debugEcho "Current directory: ", getCurrentDir()
  # debugEcho "Output file: ", nbDoc.filename

  # are these two actually needed?
  nbDoc.context["here_path"] = (nbThisFile.relativeTo nbSrcDir).string
  nbDoc.context["home_path"] = (nbSrcDir.relativeTo nbThisDir).string

  # templates are in nbSrcDir
  nbDoc.templateDirs = @[nbSrcDir.string]
  nbDoc.context["title"] = nbDoc.context["here_path"]

  # load book object
  let bookPath = "../book/book.json"
  if not bookPath.fileExists:
    withDir("..".AbsoluteDir): # todo: add a withDir for RelativeDir in nimib /paths
      discard execShellCmd("nimble dumpbook")
  var book = load(bookPath)

  # book configuration
  nbDoc.context["language"] = book.language
  nbDoc.context["default_theme"] = book.default_theme
  nbDoc.context["description"] = book.description
  nbDoc.context["favicon_escaped"] = book.favicon_escaped
  nbDoc.context["preferred_dark_theme"] = book.preferred_dark_theme
  nbDoc.context["theme_option"] = book.theme_option
  nbDoc.context["book_title"] = book.book_title
  nbDoc.context["git_repository_url"] = book.git_repository_url
  nbDoc.context["git_repository_icon"] = book.git_repository_icon

  # process toc
  for entry in book.toc.entries.mitems:
    if entry.url == nbDoc.filename.replace('\\', '/'): # replace needed for windows
      entry.isActive = true
  nbDoc.partials["toc"] = render book.toc

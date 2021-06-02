import std / [strutils, os]
import nimib, nimib / paths
import nimibook / [types, books, entries, render]

proc useNimibook*(nbDoc: var NbDoc) =
  # path handling (fix upstream in nimib)
  let
    nbThisFile = changeFileExt(nbDoc.filename.AbsoluteFile, ".nim")
    thisTuple = nbThisFile.splitFile
    pathToRootFolder = getEnv("nimibook_path_to_rootfolder")
    nbThisDir: AbsoluteDir = pathToRootFolder.toAbsoluteDir
    nbHomeDir: AbsoluteDir = nbThisDir / RelativeDir("..") / "docs".RelativeDir
    nbSrcDir = nbThisDir

# TODO comment debugEcho before merge
  debugEcho "-------------------------------"
  debugEcho ">> ", pathToRootFolder
  debugEcho ">> ", nbThisDir
  debugEcho ">> ", nbSrcDir
  debugEcho "-------------------------------"

  # Are these two actually needed? well, home_path is needed in path_to_root, but other than that?
  nbDoc.context["here_path"] = (nbThisFile.relativeTo nbSrcDir).string
  nbDoc.context["home_path"] = (nbSrcDir.relativeTo nbThisDir).string

  nbDoc.filename = relativeTo(changeFileExt(nbThisFile, ".html"), nbSrcDir).string
  nbDoc.context["path_to_root"] = nbDoc.context["home_path"].castStr & "/" # I probably should make sure to have / at the end
  # debugEcho "Current directory: ", getCurrentDir()
  # debugEcho "Output file: ", nbDoc.filename

  # templates are in nbSrcDir
  nbDoc.templateDirs = @[nbSrcDir.string]
  nbDoc.context["title"] = nbDoc.context["here_path"]

  # Use nbSrcDir instead another relative path
  let bookPath = nbSrcDir.string / "book.json"
  # load book object
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

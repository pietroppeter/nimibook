import std / [strutils, os]
import nimib, nimib / paths
import nimibook / [types, tocs, render, entries]

proc useNimibook*(nbDoc: var NbDoc) =
  let
    nbThisFile = changeFileExt(nbDoc.filename.AbsoluteFile, ".nim")
    thisTuple = nbThisFile.splitFile
    nbThisDir: AbsoluteDir = thisTuple.dir
    nbHomeDir: AbsoluteDir = findNimbleDir(nbThisDir) / "docs".RelativeDir
    nbSrcDir = nbHomeDir / RelativeDir(".." / "book")

  nbDoc.filename = relativeTo(changeFileExt(nbThisFile, ".html"), nbSrcDir).string
  nbDoc.context["here_path"] = (nbThisFile.relativeTo nbSrcDir).string
  nbDoc.context["home_path"] = (nbSrcDir.relativeTo nbThisDir).string
  echo "Current directory: ", getCurrentDir()
  echo "Output file: ", nbDoc.filename

  nbDoc.context["title"] = nbDoc.context["here_path"]
  # templates are in nbSrcDir
  nbDoc.templateDirs = @[nbSrcDir.string]
  # for mdbook
  nbDoc.context["language"] = "en-us"
  nbDoc.context["default_theme"] = "light"
  nbDoc.context["description"] = "example mdbook with nimib"
  nbDoc.context["favicon_escaped"] = """<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2280%22>🐳</text></svg>">"""
  nbDoc.context["path_to_root"] = nbDoc.context["home_path"].castStr & "/" # I probably should make sure to have / at the end
  nbDoc.context["preferred_dark_theme"] = "false"
  nbDoc.context["theme_option"] = {"light": "Light (default)", "rust": "Rust", "coal": "Coal", "navy": "Navy", "ayu": "Ayu"}.toTable
  nbDoc.context["book_title"] = "nimibook"
  nbDoc.context["git_repository_url"] = "https://github.com/pietroppeter/nimibook"
  nbDoc.context["git_repository_icon"] = "fa-github"

  let tocPath = "../book/toc.json"
  if not tocPath.fileExists:
    withDir("..".AbsoluteDir): # todo: add a withDir for RelativeDir in nimib /paths
      discard execShellCmd("nimble dumptoc")
  var toc = load(tocPath)
  for entry in toc.entries.mitems:
    if entry.url == nbDoc.filename.replace('\\', '/'): # replace needed for windows
      entry.isActive = true
  nbDoc.partials["toc"] = render toc

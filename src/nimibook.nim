import nimib / paths
import os, strutils

# A Table of Content is a container of (organized) content
type
  TocKind* = enum
    tkContainer
    tkContent
  Toc* = ref object
    label*: string
    case kind: TocKind
    of tkContainer:
      pathfolder*: RelativeDir
      contents*: seq[Toc]
    of tkContent:
      pathfile*: RelativeFile
      is_numbered*: bool

# should this be in print? I cannot test 1.0 since I am on windows and it requires 1.4.6 (which is seen as virus)
# should print be able to manage distinct stuff automatically?
import print
proc prettyPrint*(x: AnyPath; indent = 0; multiline = false): string =
  prettyPrint(x.string, indent = indent, multiline = multiline)

# move this into nimib /paths (eventually this kind of stuff might go into pathutils)
proc `/`*(x: RelativeDir, y: RelativeFile): RelativeFile =
  # I should do better than this...
  joinPath(x.string, y.string).RelativeFile

proc `/`*(x: RelativeDir, y: RelativeDir): RelativeDir =
  # I should do better than this...
  joinPath(x.string, y.string).RelativeDir

# a template based DSL
# an issue I run often into when doing this is that parameter name cannot match object field
# (e.g. title != label), otherwise I cannot set the field name
template newToc*(name: string, root: string, body: untyped): Toc =
  var
    toc = Toc(kind: tkContainer, label: name, contents: @[])
    currContent = Toc()
    currContainer = Toc()
    parentContainer = Toc()

  template chapter(title: string, file: string, numbered = true) =
    currContent = Toc(kind: tkContent, label: title, is_numbered: numbered)
    # todo: check that path is an existing file (needs to use folder of container (and container of container!), if not fail.
    currContent.pathfile = currContainer.pathfolder / RelativeFile(file)
    currContainer.contents.add currContent

  template section(title: string, folder: string, secBody: untyped) =
    parentContainer = currContainer
    currContainer = Toc(kind: tkContainer, label: title)
    # todo: check that path is an existing folder (relative to container)...
    currContainer.pathfolder = parentContainer.pathfolder / RelativeDir(folder)
    parentContainer.contents.add currContainer
    # check if index.nim exists
    chapter(title, "index.nim")
    secBody
    currContainer = parentContainer

  # todo: check that path is an existing folder, if not fail.
  toc.pathfolder = RelativeDir(root)
  currContainer = toc
  body
  toc

iterator items*(toc: Toc): Toc =
  ## iterate over toc's content
  assert toc.kind == tkContainer, "toc.kind must be container to iterate"
  for content in toc.contents:
    case content.kind:
      of tkContent:
        yield content
      of tkContainer:
        for item in content.contents:
          # todo: how do I manage sections inside sections?
          yield item

proc publish*(toc: Toc) =
  # todo: generate a toc.json object
  # todo: it is easy to support also markdown files!
  for content in toc:
    let
      cmd = "nim"
      args = ["r", "-d:release", content.pathfile.string]
    echo "[Executing] ", cmd, " ", args.join(" ")
    if execShellCmd(cmd & " " & args.join(" ")) != 0:
      quit(1)
    #I like better execShellCmd because I can see interactively the ongoing compilation and running. Alternative is:
    #echo execProcess(cmd, args=args, options={poUsePath, poEchoCmd, poStdErrToStdOut})

#[
  Why do I have a single Toc type?
  Another option would be to have distinct Toc, TocContent, TocContainer types (or at least TocContent and TocContainer).
  In the end a lot of "methods" require a specific Toc kind (publish is only for top level Toc, items only for container,
  path would return RelativeDir or RelativeFile depending on which kind of toc...)
  The issue is that in contents I can have a mix of containers and content... (is this where I need inheritance?)
]#
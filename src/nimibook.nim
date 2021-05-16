import nimib / paths
# A Table of Content is a container of (organized) content
type
  TocKind* = enum
    tkContainer
    tkContent
  Toc* = ref object
    label*: string
    case kind: TocKind
    of tkContainer:
      folder*: RelativeDir
      contents*: seq[Toc]
    of tkContent:
      file*: RelativeFile
      is_numbered*: bool

# should this be in print? I cannot test 1.0 since I am on windows and it requires 1.4.6 (which is seen as virus)
import print
proc prettyPrint*(x: AnyPath; indent = 0; multiline = false): string =
  prettyPrint(x.string, indent = indent, multiline = multiline)

# a template based DSL
# an issue I run often into when doing this is that parameter name cannot match object field
# (e.g. title != label), otherwise I cannot set the field name
template newToc*(name: string, root: string, body: untyped): Toc =
  var
    toc = Toc(kind: tkContainer, label: name, contents: @[])
    currContent = Toc()
    currContainer = Toc()
    parentContainer = Toc()

  template chapter(title: string, path: string, numbered = true) =
    currContent = Toc(kind: tkContent, label: title, is_numbered: numbered)
    # todo: check that path is an existing file (needs to use folder of container (and container of container!), if not fail.
    currContent.file = RelativeFile(path)
    currContainer.contents.add currContent

  template section(title: string, path: string, secBody: untyped) =
    parentContainer = currContainer
    currContainer = Toc(kind: tkContainer, label: title)
    # todo: check that path is an existing folder (relative to container)...
    currContainer.folder = RelativeDir(path)
    parentContainer.contents.add currContainer
    # check if index.nim exists
    chapter(title, "index.nim")
    secBody
    currContainer = parentContainer

  # todo: check that path is an existing folder, if not fail.
  toc.folder = RelativeDir(root)
  currContainer = toc
  body
  toc

iterator items*(toc: Toc): Toc =
  assert toc.kind == tkContainer, "toc.kind must be container to iterate"
  for content in toc.contents:
    case content.kind:
      of tkContent:
        yield content
      of tkContainer:
        for item in content.contents:
          yield item

# newTok creates a Toc of kind container
# publish toc:
#   - generates a toc.json (to be ignored by git?)
#   - run all the code for toc items (and they will generate the html and have a mechanism in nbPostInit to use the toc.json)

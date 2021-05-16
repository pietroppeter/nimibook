import nimib / paths
# A Table of Content is a container of (organized) content
type
  TocKind = enum
    container
    content
  Toc = ref object
    label: string
    case kind: TocKind
    of container:
      folder: RelativeDir
      contents: seq[Toc]
    of content:
      file: RelativeFile
      is_numbered: bool

# should this be in print? I cannot test 1.0 since I am on windows and it requires 1.4.6 (which is seen as virus)
import print
proc prettyPrint*(x: AnyPath; indent = 0; multiline = false): string =
  prettyPrint(x.string, indent = indent, multiline = multiline)

# a template based DSL
# an issue I run often into when doing this is that parameter name cannot match object field
# (e.g. title != label), otherwise I cannot set the field name
template newToc*(title: string, path: string, body: untyped): Toc =
  let toc = Toc(kind: container, contents: @[])
  # todo: check that path is an existing folder, if not fail.
  toc.folder = RelativeDir(path)
  toc.label = title
  body
  toc

template chapter*(title: string, path: string, numbered = true): untyped =
  let chp = Toc(kind: content, label: title, is_numbered: numbered)
  # todo: check that path is an existing file (needs to use folder of container (and container of container!), if not fail.
  chp.file = RelativeFile(path)
  toc.contents.add chp
# Error: undeclared identifier
# WHY?

# newTok creates a Toc of kind container
# publish toc:
#   - generates a toc.json (to be ignored by git?)
#   - run all the code for toc items (and they will generate the html and have a mechanism in nbPostInit to use the toc.json)

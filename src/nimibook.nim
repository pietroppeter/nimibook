type
  TocKind = enum
    section
    page
  Toc = ref object
    case kind: TocKind
    of section:
      items: seq[Toc]
    of page:
      label: string
      path: string
      is_numbered: bool

# newTok creates a Toc of kind section
# publish toc:
#   - generates a toc.json (to be ignored by git?)
#   - run all the code for toc items (and they will generate the html and have a mechanism in nbPostInit to use the toc.json)

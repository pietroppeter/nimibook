import std / strformat
import nimibook / [types, entries]

proc closeSection(): string =
  result.add """
  </ol>
  </li>
"""

proc openSection(): string =
  result.add """
  <li>
  <ol class="section">
"""

proc addEntryImpl(e: Entry, path_to_root: string): string =
  let active = if e.isActive: " class=\"active\"" else: ""
  result.add "<li class=\"chapter-item expanded \">\n"
  if e.isDraft:
    result.add "  <div>\n"
  else:
    result.add &"  <a href=\"{path_to_root}{e.url}\"{active} tabindex=\"0\">\n"
  if e.isNumbered:
    result.add &"    <strong aria-hidden=\"true\">{e.number}</strong> {e.title}\n"
  else:
    result.add &"      {e.title}\n"
  if e.isDraft:
    result.add "  </div>\n"
  else:
    result.add "  </a>"
  result.add "</li>\n"

proc openGenToc(): string =
  result.add """
<ol class="chapter">
"""

proc closeGenToc(): string =
  # Close last opened section that will not be closed anywhere
  # result.add closeSection()
  result.add """
</ol>
"""

proc render*(toc: Toc, path_to_root: string): string =
  ## renders toc as a mustache partial
  # assume entries are sorted
  result.add openGenToc()
  var previousLevel = 1
  for e in toc.entries:
    if len(e.levels) == previousLevel:
      discard
    elif len(e.levels) > previousLevel:
      result.add openSection()
    else:
      for _ in 1 .. (previousLevel - len(e.levels)):
        result.add closeSection()

    result.add addEntryImpl(e, path_to_root)
    previousLevel = len(e.levels)
  result.add closeGenToc()

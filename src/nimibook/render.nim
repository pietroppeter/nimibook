import strformat
import nimibook / types

const path_to_root = "{{path_to_root}}"

proc closeSection() : string =
  result.add """
  </ol>
  </li>
"""

proc openSection() : string =
  result.add """
  <li>
  <ol class="section">
"""

proc addEntryImpl(e: Entry) : string =
  debugEcho &"    makeChapter => {e.title} : {e.url} => {e.levels}"
  if e.isNumbered:
    var chapNumber  : string
    for i in e.levels:
      chapNumber.add $i
      chapNumber.add "."

    result.add &"""
  <li class="chapter-item expanded ">
    <a href="{path_to_root}{e.url}" tabindex="0">
      <strong aria-hidden="true">{chapNumber}</strong> {e.title}
    </a>
  </li>
"""
  else:
    result.add &"""
  <li class="chapter-item expanded ">
    <a href="{path_to_root}{e.url}" tabindex="0">
      {e.title}
    </a>
  </li>
"""

proc openGenToc() : string =
  result.add """
<ol class="chapter">
"""

proc closeGenToc() : string =
  # Close last opened section that will not be closed anywhere
  # result.add closeSection()
  result.add """
</ol>
"""

proc render*(toc: Toc): string =
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
      result.add closeSection()

    result.add addEntryImpl(e)
    previousLevel = len(e.levels)
  result.add closeGenToc()

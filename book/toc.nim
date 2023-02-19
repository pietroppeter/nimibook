import nimib, nimibook

nbInit(theme = useNimibook)
nbText: """## Table of Contents

The Table of Contents (ToC) is defined inside the `nbook.nim`
(you can pick another name for the file but in the documentation we will refer to it as `nbook.nim`).
As an example here is `nbook.nim` for this book (nimibook documentation):
"""
nbCode:
  discard
nb.blk.code = "../nbook.nim".readFile
nbText: """
From the above example you can see that:
  - ToC is defined inside `initBookWithToc` block
  - chapters that do not start a section are created with `entry`
  - `entry` accepts two string parameters: chapter title and source path
  - source path is relative to book source folder
  - source extension defaults to `.nim`, to use a markdown source you need to explict mark it as `.md`
  - chapters that start a section are created with `section` and start a new block
  - draft chapters (placeholders in the ToC without source) are created with `draft` 

In the future nimibook will support the same `SUMMARY.md` mechanism as in mdbook.
Note that currently nimibook does not support part title and separators (available in mdbook).
"""
nbSave

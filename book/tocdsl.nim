import nimib, nimibook
nbInit
nbUseNimibook

nbText: """
# Table of Contents DSL

The table of content supports (numbered) chapters (`entry`),
sections (`section`) and draft chapters (`draft`, not numbered).

Here is an example on how it looks like
```nim
import nimibook, os # os is used inside Toc DSL

let toc = newToc("Example", "book"):
  entry("Introduction", "index") # .nim extension is optional
  entry("Pure Markdown", "pure.md") # for md files you need to use extension
  # every entry in this section will have a path relative to basics
  section("Basics", "basics/index.nim"):
    section("Plotting", "plotting.nim"): # nested sections
      entry("Data Manipulation", "data_manipulation")
    entry("Models", "models") 
  draft("Contributors", "misc/but/very/far/contributors")
```
""" # todo: highlight nim code
nbSave
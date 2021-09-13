import nimib, nimibook
import std / [os, strutils, strscans, strformat]

nbInit(theme = useNimibook)

# the following is very dependent on how source is written
proc readBookConfigFields: seq[string] =
  # current folder is docs
  let src = "../src/nimibook/types.nim"
  var process = false
  var field, typ, description: string
  for line in src.lines:
    # debugEcho line
    if line.strip.startsWith("Book"):
      # debugEcho ">start processing"
      process = true
      continue
    if line.strip.startsWith("#"):
      # debugEcho ">skip"
      continue
    if line.strip.startsWith("toc"):
      # debugEcho ">stop processing"
      break
    if process and line.contains("##"):
      # debugEcho ">match"
      description = line.split("##")[1].strip
      field = line.split("##")[0].split("*:")[0].strip
      typ = line.split("##")[0].split("*:")[1].strip
      result.add fmt"* **{field}** (`{typ}`): {description}"
    # else: debugEcho ">noMatch"

let fieldList = readBookConfigFields().join("\n")

nbText: fmt"""
# Configuration

Book configuration is done with the `Book` object that has been created with `newBookFromToc`.

The `Book` object has the following fields which are relevant for the documentation:

{fieldList}

Notes:

* for consistency with template values, we use snake case for fields of this object.
* the book object replicates functionalities available in mdbook
* relevant documentation for mdbook is in this two pages:
    - <https://rust-lang.github.io/mdBook/format/theme/index-hbs.html>
    - <https://rust-lang.github.io/mdBook/format/config.html>
* if not indicated otherwise, these fields are present in `document.mustache` and they are directly adapted from `index.hbs`
* documentation comments above come directly from mdbook documentation (unless otherwise stated)
"""
nbSave
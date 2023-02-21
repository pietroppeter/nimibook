import nimib, nimibook
import std / [os, strutils, strformat]
import nimibook / [defaults, configs]

func skipUntil*(text: string, keyword: string): string =
  var untilReached = false
  var lines: seq[string]
  for line in text.splitLines:
    if line.startsWith(keyword):
      untilReached = true
    if untilReached:
      lines.add line
  result = lines.join("\n")

nbInit(theme = useNimibook)

template debug(message: string) =
  when defined(nimibookDebugConfigurationDoc):
    debugEcho message

# the following is very dependent on how source is written
proc readBookConfigFields: seq[string] =
  # current folder is docs
  let src = "../src/nimibook/types.nim"
  var process = false
  var field, typ, description: string
  for line in src.lines:
    debug line
    if line.strip.startsWith("BookConfig"):
      debug ">start processing"
      process = true
      continue
    if line.strip.startsWith("#"):
      debug ">skip"
      continue
    if line.strip.startsWith("Book"):
      debug ">stop processing"
      break
    if process and line.contains("##"):
      debug ">match"
      description = line.split("##")[1].strip
      field = line.split("##")[0].split("*:")[0].strip
      typ = line.split("##")[0].split("*:")[1].strip
      result.add fmt"* **{field}** (`{typ}`): {description}"
    else:
      debug ">noMatch"

let fieldList = readBookConfigFields().join("\n")

nbText: fmt"""
# Configuration

Book configuration is done inside the `[nimibook]` section of `nimib.toml` configuration file.

Here are the available fields:

{fieldList}

As an example here is nimibook configuration:"""
nbCode: # highlight as nim since it is better than no highlighting...
  discard
nb.blk.code = "../nimib.toml".readFile
nbText: "This is the default configuration created by the `init command`:"
nbCode: # highlight as nim since it is better than no highlighting...
  discard
nb.blk.code = block:
  var book = Book()
  book.setDefaults
  book.renderConfig.skipUntil("[nimibook]")


nbText: """
## Folder structure
By default the nimibook folder structure is to put all sources in a `book` folder
and to put the book built output in a `docs` folder (so that it is straightforward to publish the book with github pages).

These folders can be customized since they are taken from [nimib] section of `nimib.toml`
as `srcDir` and `homeDir`.

### where does nimibook puts the output html?

The logic of nimibook is that for every source, the **relative path** with respect to `srcDir` is applied as relative path to `homeDir` and this will give the html output path.
For example, if we have default values `srcDir="book";homeDir="docs"`:
  - a source in `book\example.md` will generate `docs\example.html`
  - a source in `book\folder\subfolder\example.nim` will generate `docs\folder\subfolder\example.html`

## Additional remarks
* for consistency with template values, we use snake case for fields of this object.
* the book object replicates functionalities available in mdbook
* relevant documentation for mdbook is in this two pages:
    - <https://rust-lang.github.io/mdBook/format/theme/index-hbs.html>
    - <https://rust-lang.github.io/mdBook/format/config.html>
* if not indicated otherwise, these fields are present in `document.mustache` and they are directly adapted from `index.hbs`
* documentation comments above come directly from mdbook documentation (unless otherwise stated)
"""
nbSave
import nimib, nimibook
nbInit
nbUseNimibook

nbText: """
# Content

The content of a chapter of a book can be a standard Markdown file or a nim file.

For the nim file the structure is the following:

```nim
import nimib, nimibook
... # other imports

nbInit # initializes a nimib document
nbUseNimibook # overrides nimib defaults with nimibooks and loads book configuration

... # content of chapter using nbText, nbCode and other nimib functionalities

nbSave # save the document to html output
```
""" # todo: highlight nim code
nbSave
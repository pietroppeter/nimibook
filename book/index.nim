import nimib, nimibook
import strutils
nbInit(theme = useNimibook)

proc readFileUntil(filename: string, text: string): string =
  for line in filename.lines:
    if line.startsWith(text):
      return result
    result &= line & '\n'

nbText: "../README.md".readFileUntil("<!--SKIP")
nbSave

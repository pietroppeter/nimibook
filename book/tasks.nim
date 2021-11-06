import nimib, nimibook
import osproc, sugar, strutils, strformat

nbInit(theme = useNimibook)

var tasks: string
withDir("..".AbsoluteDir):
  tasks = execProcess("nimble", args=["tasks"], options={poUsePath})

let taskList = collect(newSeq):
  for line in tasks.strip.splitLines:
    "* `nimble " & line.replace("        ", "`: ")

nbText: fmt"""
# Tasks

{taskList.join("\n")}
"""
nbSave
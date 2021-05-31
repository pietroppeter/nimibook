import std / [os, strutils]

proc joinPath*(parts: seq[string], tail: string): string =
  var parts = parts
  parts.add tail
  normalizedPath(joinPath(parts))

proc formatFileName*(inputs: tuple[dir: string, name: string, ext: string]): string =
  result = inputs.name
  if inputs.ext.isEmptyOrWhitespace():
    result &= ".nim"
  else:
    result &= inputs.ext

# in case you need to sort entries (it can be useful for automatically generated entries)
import nimibook / types
import std/algorithm

proc intcmp(x, y: int): int =
  if x < y:
    return -1
  elif x == y:
    return 0
  else:
    return 1

proc mycmp(x, y: seq[int]): int =
  var idx = 0
  var r = intcmp(x[idx], y[idx])
  while r == 0:
    inc(idx)
    if idx >= x.len() and idx < y.len():
      return -1
    if idx >= y.len() and idx < x.len():
      return 1
    else:
      r = intcmp(x[idx], y[idx])
  return r

proc entrycmp(x, y: Entry): int =
  let r = mycmp(x.levels, y.levels)
  doAssert(r != 0, "Entry cannot be equal")
  return r

proc sort*(toc: var Toc) =
  toc.entries = toc.entries.sorted(entrycmp)

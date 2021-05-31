import std / os
import nimibook /  [types, entries]
import jsony

# fix for jsony: quote in string. https://github.com/treeform/jsony/issues/14
proc dumpHook*(s: var string, v: string) =
  when nimvm:
    s.add '"'
    for c in v:
      case c:
      of '\\': s.add r"\\"
      of '\b': s.add r"\b"
      of '\f': s.add r"\f"
      of '\n': s.add r"\n"
      of '\r': s.add r"\r"
      of '\t': s.add r"\t"
      of '"': s.add r"\"""
      else:
        s.add c
    s.add '"'
  else:
    # Its faster to grow the string only once.
    # Then fill the string with pointers.
    # Then cap it off to right length.
    var at = s.len
    s.setLen(s.len + v.len*2+2)

    var ss = cast[ptr UncheckedArray[char]](s[0].addr)
    template add(ss: ptr UncheckedArray[char], c: char) =
      ss[at] = c
      inc at
    template add(ss: ptr UncheckedArray[char], c1, c2: char) =
      ss[at] = c1
      inc at
      ss[at] = c2
      inc at

    ss.add '"'
    for c in v:
      case c:
      of '\\': ss.add '\\', '\\'
      of '\b': ss.add '\\', 'b'
      of '\f': ss.add '\\', 'f'
      of '\n': ss.add '\\', 'n'
      of '\r': ss.add '\\', 'r'
      of '\t': ss.add '\\', 't'
      of '"': ss.add '\\', '"'
      else:
        ss.add c
    ss.add '"'
    s.setLen(at)

proc dump*(book: Book) =
  let uri = normalizedPath(book.toc.path / "book.json")
  writeFile(uri, book.toJson)

proc clean*(book: Book) =
  let uri = normalizedPath(book.toc.path / "book.json")
  removeFile(uri)

proc load*(path: string): Book =
  let uri = normalizedPath(path)
  readFile(uri).fromJson(Book)

proc check*(book: Book) =
  for entry in book.toc.entries:
    entry.check()
  echo "Check toc => OK"

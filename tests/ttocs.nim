import unittest
import std / strutils
import nimibook / [tocs, entries, types, renders]

test "toc dsl":
  var book: Book
  book.toc = initToc:
    entry("Introduction", "index.nim", numbered = false)
    section("Part 1", "part1/index.nim"):
      entry("This is important", "important.nim")
      entry("Also this", "also.nim")
      entry("this a little less", "less.nim")
      section("subsection", "sub.nim"):
        entry("and this may be skipped", "skip.nim")
    section("Part 2", "part2/index.md"):
      entry("this might be interesting", "mmh.md")
      draft("and I have not written this yet")
    entry("Appendix", "appendix.md", numbered = false)

  echo book.renderToc
  check len(book.toc.entries) == 11
  check book.toc.entries[0].url == "index.html"
  check book.toc.entries[1].url == "part1/index.html"
  check book.toc.entries[2].url == "part1/important.html"

test "toc render": # issue 73
  let myToc = initToc:
    entry("Should Be 1.", "book/bla.nim")
    section("Should be 2", "book/internals.nim"):    
      section("Should be 2.1", "internals/adders.nim"):
        entry("Should be 2.1.1", "adders/one_adder.nim")

    entry("Should be 3.", "CONTRIBUTING.md")
  let renderedToc = myToc.render
  check renderedToc.count("<ol") == renderedToc.count("</ol>")
  check renderedToc.count("<li") == renderedToc.count("</li>")
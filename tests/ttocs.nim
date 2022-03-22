import unittest
import nimibook / [tocs, entries, types]

test "toc dsl":
  let toc = initToc:
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

  check len(toc.entries) == 11
  check toc.entries[0].url == "index.html"
  check toc.entries[1].url == "part1/index.html"
  check toc.entries[2].url == "part1/important.html"

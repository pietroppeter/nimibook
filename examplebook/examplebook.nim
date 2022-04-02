import nimibook

var book = initBookWithToc:
  entry("Preface", "preface.md", numbered = false)
  entry("Introduction", "intro.md")
  section("Chapter 1", "chapter1/index.nim"):
    entry("Content", "content.nim")
    draft("Nothing yet")
    section("Sub chapter", "no_ext"):
      entry("and some more content", "more.md")

nimibookCli(book)


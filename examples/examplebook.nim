import nimibook, os
nimibookCli

var book = newBookFromToc("Dummy Book", "book"):
  section("Dummy", "index"):
    entry("Simple example", "book_1")


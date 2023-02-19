import nimibook

var book = initBookWithToc:
  entry("Introduction", "index", numbered = false) # .nim extension is optional
  entry("Content", "content")
  entry("Table of Contents", "toc")
  entry("Configuration", "configuration")
  entry("Commands", "cli")
  section("Example toc structure", "tocexample/index.md"):
    section("Nested section", "nested.md"):
      entry("Entry in nested section", "nested_entry.md")
    entry("Back to parent section", "back_to_parent.md")
    draft("Draft chapter")

nimibookCli(book)

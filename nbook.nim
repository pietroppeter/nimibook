import nimibook

var book = initBookWithToc:
  section("Introduction", "index"): # .nim extension is optional
    entry("Content", "content")
    entry("Toc DSL", "tocdsl")
    entry("Configuration", "configuration")
    entry("Nimble tasks", "tasks")
    entry("Latex", "latex")
  section("Example toc structure", "tocexample/index.md"):
    section("Nested section", "nested.md"):
      entry("Entry in nested section", "nested_entry.md")
    entry("Back to parent section", "back_to_parent.md")
    draft("Draft chapter")

nimibookCli(book)

import nimibook

var book = newBookFromToc("nimibook", "book"):
  section("Introduction", "index"): # .nim extension is optional
    entry("Content", "content")
    entry("Toc DSL", "tocdsl")
    entry("Configuration", "configuration")
    entry("Tasks", "tasks")
  section("Example toc structure", "tocexample/index.md"):
    section("Nested section", "nested.md"):
      entry("Entry in nested section", "nested_entry.md")
    entry("Back to parent section", "back_to_parent.md")
    draft("Draft chapter", "draft.md")

book.git_repository_url = "https://github.com/pietroppeter/nimibook"
book.plausible_analytics_url = "pietroppeter.github.io/nimibook"
nimibookCli(book)

import nimibook, os # os is used inside Toc DSL

var book = newBookFromToc("nimibook", "book"):
  section("Introduction", "index"): # .nim extension is optional
    entry("Content", "content")
    entry("Toc DSL", "tocdsl")
    draft("Configuration", "configuration.md")
    entry("Tasks", "tasks")

nbBookTasks
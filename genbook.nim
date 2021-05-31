import nimibook, os # os is used inside Toc DSL

let toc = newToc("nimibook", "book"):
  section("Introduction", "index"): # .nim extension is optional
    entry("Content", "content")
    entry("Toc DSL", "tocdsl")
    draft("Configuration", "configuration.md")
    entry("Tasks", "tasks")

nbBookTasks
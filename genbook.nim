import nimibook, os

let toc = newToc("Example", "book"):
  entry("Introduction", "index")
  # .nim extension is optionnal but you can add it if you want to
  section("Basics", "basics/index.nim"):
    section("Plotting", "plotting.nim"):
      entry("Data Manipulation", "data_manipulation")
    entry("Models", "models")
  draft("Contributors", "misc/but/very/far/contributors")

when defined(printToc):
  import print
  print toc
elif defined(dumpToc):
  dump toc
elif defined(cleanToc):
  clean toc
else:
  publish toc

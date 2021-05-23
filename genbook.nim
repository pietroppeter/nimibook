import nimibook, os

let toc = newToc("Example", "book"):
  entry("Introduction", "index.nim")
  entry("Basics", "basics/index.nim"):
    entry("Plotting", "plotting.nim")
    entry("Data Manipulation", "data_manipulation.nim")
    entry("Models", "models.nim")
  draft("Contributors", "misc/but/very/far/contributors.nim")

when defined(printToc):
  import print
  print toc
elif defined(dumpToc):
  dump toc
elif defined(cleanToc):
  clean toc
else:
  publish toc

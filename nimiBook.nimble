# Package

version       = "0.1.0"
author        = "Pietro Peterlongo"
description   = "A port of mdbook to nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.0"
requires "nimib >= 0.1.2"

import os
task genbook, "genbook":
  selfExec("r -d:release nbook.nim")

task cleanbook, "cleanbook":
  # todo: it should remove all files and directories not tracked in git from docs
  for file in walkDirRec("docs"):
    if file.endsWith(".html"):
      rmFile(file)
      echo "removed ", file
      

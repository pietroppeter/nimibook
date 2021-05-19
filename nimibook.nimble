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
task gentoc, "gentoc":
  selfExec("r -f src/tocgen.nim")

task genhtml, "genhtml":
  for path in walkDirRec("books"):
    let (dir, name, ext) = path.splitFile()
    if ext == ".nim" and name notin ["nbPostInit.nim"]:
      echo "building ", path
      selfExec("r -d:nimibCustomPostInit " & path)

task genbook, "genbook":
  gentocTask()
  genhtmlTask()

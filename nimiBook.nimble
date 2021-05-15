# Package

version       = "0.1.0"
author        = "Pietro Peterlongo"
description   = "A port of mdbook to nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.0"
requires "nimib >= 0.1.1"

import os
task genbook, "genbook":
  for path in walkDirRec("."):
    let (dir, name, ext) = path.splitFile()
    if ext == ".nim" and name not_in ["nbPostInit"]:
      echo "building ", path
      selfExec("r " & path)
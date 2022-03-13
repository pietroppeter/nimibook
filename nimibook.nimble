# Package

version       = "0.3.0"
author        = "Pietro Peterlongo"
description   = "A port of mdbook to nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.0"
requires "nimib >= 0.2.1"
requires "jsony >= 1.0.3"

import os

task genbook, "build book":
  selfExec(" r -d:release nbook.nim init")
  selfExec(" r -d:release nbook.nim build")

task dumpbook, "dump book.json":
  selfExec(" r -d:release nbook.nim dump")

task cleanbook, "remove all files created during build":
  selfExec(" r -d:release nbook.nim clean ")

task srcpretty, "run nimpretty on nim files in src folder":
  for file in walkDirRec("src"):
    if file.endsWith(".nim"):
      let cmd = "nimpretty --maxLineLen:160 " & file
      echo "[executing] ", cmd
      exec(cmd)

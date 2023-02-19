import std / [os, strformat]
import nimibook / types
import nimib / [config, paths]

proc renderConfig*(book: Book): string =
  fmt"""
[nimib]
srcDir = "{book.nbCfg.srcDir.string}"
homeDir = "{book.nbCfg.homeDir.string}"

[nimibook]
language = "{book.cfg.language}"
title = "{book.cfg.title}"
description = "{book.cfg.description}"
"""

proc loadConfig*(book: var Book) =
  let cfg = loadNimibCfg("nimib.toml")
  if not cfg.found:
    echo "[nimibook.warning] config file nimib.toml not found (using current directory as cfgDir)"
    book.cfgDir = getCurrentDir().AbsoluteDir
    book.nbCfg.srcDir = "book"
    book.nbCfg.homeDir = "docs"
  else:
    book.cfgDir = cfg.dir
    book.rawCfg = cfg.raw
    book.nbCfg = cfg.nb
  book.cfg = loadTomlSection(book.rawCfg, "nimibook", BookConfig)
  echo book.renderConfig

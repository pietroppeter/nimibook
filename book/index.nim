import nimib, nimibook / cfg
nbInit
nbDoc.applyCfg
nbText: """# Introduction

I should say something very wise about this book.

Instead I will just post some nim code:
"""
nbCode:
  echo "hello mdbook!"
nbSave
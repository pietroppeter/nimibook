import nimibook
# run to generate the book
toc = newToc("book")
# generate automatically table of content from folder,
# ordering should take into account a special keyword like index and folder structure
# in current case basics/data_manipulation will come first and plotting last.
#[
Alternative syntax (manual inclusion of content, more control) could be something like

toc = newToc("book"):
  Chapter("index.nim", "Introduction")
  Chapter("basics/index.nim", "Basics"):
    Section("basics/plotting.nim", "Data Visualization")
    Section("basics/data_manipulation.nim", "Data Manipulation")
    Section("basics/models.nim", "Models")
  Chapter("misc/but/very/far/contributors.nim", "Contributors", numbered=false)

Alternative mechanism (SUMMARY.md like in mdbook):

toc = newToc("book/SUMMARY.md")

where SUMMARY.md is:

  # Summary

  - [Introduction](index.nim)
  - [Basics](basics/index.nim)
    - [Data Visualization](basics/plotting.nim)
    - [Data Manipulation](basics/data_manipulation.nim)
    - [Models](basics/models.nim)
  
  [misc/but/very/far/contributors.nim](Contributors)
    
]#
publish toc
import nimib, nimibook

nbInit

nbUseNimibook # overrides nimib defaults with nimibooks and loads book configuration

nbText: "Hello world"

nbCode:
  doAssert 1+2 == 3

nbSave

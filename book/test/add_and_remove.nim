import nimib, nimibook

nbInit
nbUseNimibook

nbCode:
  let text = "appear"
  for i in 0 .. text.high:
    echo text[0 .. i]
nbSave

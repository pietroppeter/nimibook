template populateAssets*(rootfolder: string, force: bool = false) =  
  const assetsSrc = currentSourcePath().parentDir() / "assets"
  let
    assetsTarget = getCurrentDir() / "docs" / "assets"

  if not dirExists(assetsTarget):
    echo "[nimibook] creating assets directory: ", assetsTarget
    copyDir(assetsSrc, assetsTarget)
  else:
    if force:
      removeDir(assetsTarget)
      echo "[nimibook] removing and creating again assets directory: ", assetsTarget
      copyDir(assetsSrc, assetsTarget)

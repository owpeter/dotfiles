{ pkgs, lib, ... }:

let
  dotfilesSrc = lib.cleanSource ../../.;
  scriptsPath = dotfilesSrc + "/resource/scripts";
  helpersPath = dotfilesSrc + "/resource/helpers";


  packageScriptsFromDir = dirPath:
    let dirContents = builtins.readDir dirPath;
    in
    lib.mapAttrsToList
      (scriptName: fileType:
        if fileType == "regular" then
          pkgs.writeShellScriptBin scriptName (builtins.readFile (dirPath + "/${scriptName}"))
        else
          null
      )
      dirContents;
  packagedScripts = packageScriptsFromDir scriptsPath;
  packagedHelpers = packageScriptsFromDir helpersPath;

in
{
  home.packages = packagedScripts ++ packagedHelpers;
}
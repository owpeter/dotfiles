###################################
#
#
#   SYSTEM PACKAGES FOR MYSYSTEM
#
#
###################################
{ lib, aLib, ... }:

let 
  systempkgs = [
    "cifs-utils"
    "openssh-server"
  ];
in
{
  home.activation.installSystemPkgs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${aLib.initSudoPwd}
    ${aLib.esudoFn}
    if [ -z $DRY_RUN_CMD ]; then
      esudo ${aLib.cmds.apt} update
      esudo ${aLib.cmds.apt} install -y ${builtins.concatStringsSep " " systempkgs}
    fi
  '';
}
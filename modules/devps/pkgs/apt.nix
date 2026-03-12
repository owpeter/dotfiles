###################################
#
#
#   SYSTEM PACKAGES FOR MYSYSTEM
#
#
###################################
{ lib, sys, ... }:

let 
  systempkgs = [
    "cifs-utils"
    "openssh-server"
  ];
in
{
  home.activation.installSystemPkgs = sys.task.root {
    script = ''
      esudo ${sys.cmds.apt} update
      esudo ${sys.cmds.apt} install -y ${builtins.concatStringsSep " " systempkgs}
    '';
  };
}
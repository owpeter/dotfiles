###################################
#
#
#   SYSTEM PACKAGES FOR MYSYSTEM
#
#
###################################
{ pkgs, config, secrets, lib, ... }: 

let 
  systempkgs = [
    "cifs-utils"
  ];
in
{
  home.activation.installSystemPkgs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SECRET_FILE="$HOME/.config/dotfiles/secrets.nix"
    if [ ! -f "$SECRET_FILE" ]; then
      echo "No password file found at $SECRET_FILE."
      exit 0
    fi
    SUDO_PWD=$(${pkgs.gnugrep}/bin/grep -w "home\.passwd" "$SECRET_FILE" | sed -n "s/.*home\.passwd[[:space:]]*=[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1)      
    if [ -z "$SUDO_PWD" ]; then
      echo "Failed to extract password from $SECRET_FILE."
      exit 1
    fi
    HOST_SUDO="/usr/bin/sudo"
    HOST_SH="/bin/sh"
    HOST_APT="/usr/bin/apt"
    if [ -z $DRY_RUN_CMD ]; then
      echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_APT update
      echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_APT install -y ${builtins.concatStringsSep " " systempkgs}
    fi
  '';
}
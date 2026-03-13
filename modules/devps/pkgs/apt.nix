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
  pkgStrings = lib.concatMapStringsSep " " (pkg: "\"${pkg}\"") systempkgs;
in
{
  home.activation.installSystemPkgs = sys.task.root {
    pre = ''
      RAW_PKGS=(${pkgStrings})
      MISSING_PKGS=""
    '';
    script = ''
      if [ ''${#RAW_PKGS[@]} -gt 0 ]; then
        for item in "''${RAW_PKGS[@]}"; do
          PKG="$item"

          if ${sys.cmds.dpkgQuery} -W -f='$'"{Status}" "$PKG" 2>/dev/null | ${sys.cmds.grep} -q "ok installed"; then
            echo "Package '$PKG' is already installed. Skipping."
            continue
          fi

          echo "Package '$PKG' not found. install..."
          MISSING_PKGS="$MISSING_PKGS $PKG"
        done

        if [ -n "$MISSING_PKGS" ]; then
          esudo ${sys.cmds.apt} update
          esudo ${sys.cmds.apt} install -y $MISSING_PKGS
        else
          echo "All system packages already satisfied."
        fi
      fi
    '';
  };
}
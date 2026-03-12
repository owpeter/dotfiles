{ pkgs, ... }:

let
  aLib = rec {
    cmds = {
      sudo = "/usr/bin/sudo";
      sh = "/bin/sh";
      apt = "/usr/bin/apt";
      systemctl = "/usr/bin/systemctl";
      usermod = "/usr/sbin/usermod";
      touch = "/usr/bin/touch";
      dpkg = "/usr/bin/dpkg";
      dpkgQuery = "/usr/bin/dpkg-query";
    };

    initSudoPwd = ''
      SECRET_FILE="$HOME/.config/dotfiles/secrets.nix"
      SUDO_PWD=""
      if [ -f "$SECRET_FILE" ]; then
        SUDO_PWD=$(${pkgs.gnugrep}/bin/grep -w "home\.passwd" "$SECRET_FILE" | sed -n "s/.*home\.passwd[[:space:]]*=[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1)
      fi
    '';

    esudoFn = ''
      esudo() {
        if [ -n "''${SUDO_PWD:-}" ]; then
          printf '%s\n' "$SUDO_PWD" | ${cmds.sudo} -S "$@"
        else
          ${cmds.sudo} "$@"
        fi
      }
    '';
  };
in
{
  _module.args.aLib = aLib;
}

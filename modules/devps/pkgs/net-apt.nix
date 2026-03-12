{ pkgs, config, secrets, lib, isDesktop, ... }:

let 
  systempkgs = [
    { 
      cmd = "wechat"; 
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"; 
    }
  ];
  pkgStrings = lib.concatMapStringsSep " " (obj: "\"${obj.cmd}|${obj.url}\"") systempkgs;
in
{
  home.activation.installNetworkSystemPkgs = lib.mkIf isDesktop (lib.hm.dag.entryAfter ["writeBoundary"] ''
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
    HOST_APT="/usr/bin/apt"
    HOST_DPKG="/usr/bin/dpkg"
    HOST_DPKG_QUERY="/usr/bin/dpkg-query"
    RAW_PKGS=(${pkgStrings})
    DOWNLOAD_LIST=""

    if [ -z "$DRY_RUN_CMD" ] && [ ''${#RAW_PKGS[@]} -gt 0 ]; then
      TEMP_DIR=$(mktemp -d)

      for item in "''${RAW_PKGS[@]}"; do
        CMD=''${item%%|*}
        URL=''${item#*|}
        if ! $HOST_DPKG_QUERY -W -f='$'"{Status}" "$CMD" | grep -q "ok installed"; then
          echo "Command '$CMD' not found. Preparing to install from $URL..."
          filename=$(basename "$URL")
          target="$TEMP_DIR/$filename"
          ${pkgs.curl}/bin/curl -L "$URL" -o "$target"
          DOWNLOAD_LIST="$DOWNLOAD_LIST $target"
        else
          echo "Command '$CMD' is already installed. Skipping."
        fi
      done
      if [ -n "$DOWNLOAD_LIST" ]; then
        echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_APT update
        echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_APT install -y $DOWNLOAD_LIST
      fi

      rm -rf "$TEMP_DIR"
    fi
  '');
}
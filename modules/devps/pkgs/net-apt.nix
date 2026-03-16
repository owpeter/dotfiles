{ pkgs, lib, isDesktop, sys, ... }:

let 
  systempkgs = [
    # systempkgs both desktop and server use
  ] ++ lib.optionals isDesktop [
    { 
      pkg = "wechat"; 
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"; 
    }
    {
      pkg = "sunshine";
      url = "https://github.com/LizardByte/Sunshine/releases/download/v2026.311.154809/sunshine-ubuntu-24.04-amd64.deb";
    }
  ];
  pkgStrings = lib.concatMapStringsSep " " (obj: "\"${obj.pkg}|${obj.url}\"") systempkgs;
in
{
  home.activation.installNetworkSystemPkgs = lib.mkIf isDesktop (sys.task.root {
    pre = ''
      RAW_PKGS=(${pkgStrings})
      DOWNLOAD_LIST=""
    '';
    script = ''
      if [ ''${#RAW_PKGS[@]} -gt 0 ]; then
        TEMP_DIR=$(mktemp -d)

        for item in "''${RAW_PKGS[@]}"; do
          PKG=''${item%%|*}
          URL=''${item#*|}
          if ! pkg_installed "$PKG"; then
            echo "Package '$PKG' not found. Preparing to install from $URL..."
            filename=$(basename "$URL")
            target="$TEMP_DIR/$filename"
            ${pkgs.curl}/bin/curl -L "$URL" -o "$target"
            DOWNLOAD_LIST="$DOWNLOAD_LIST $target"
          else
            echo "Package '$PKG' is already installed. Skipping."
          fi
        done
        if [ -n "$DOWNLOAD_LIST" ]; then
          esudo ${sys.cmds.apt} update
          esudo ${sys.cmds.apt} install -y $DOWNLOAD_LIST
        fi

        rm -rf "$TEMP_DIR"
      fi
    '';
  });
}
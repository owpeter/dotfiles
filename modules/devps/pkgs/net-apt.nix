{ pkgs, lib, isDesktop, aLib, ... }:

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
    ${aLib.initSudoPwd}
    ${aLib.esudoFn}
    RAW_PKGS=(${pkgStrings})
    DOWNLOAD_LIST=""

    if [ -z "$DRY_RUN_CMD" ] && [ ''${#RAW_PKGS[@]} -gt 0 ]; then
      TEMP_DIR=$(mktemp -d)

      for item in "''${RAW_PKGS[@]}"; do
        CMD=''${item%%|*}
        URL=''${item#*|}
        if ! ${aLib.cmds.dpkgQuery} -W -f='$'"{Status}" "$CMD" | grep -q "ok installed"; then
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
        esudo ${aLib.cmds.apt} update
        esudo ${aLib.cmds.apt} install -y $DOWNLOAD_LIST
      fi

      rm -rf "$TEMP_DIR"
    fi
  '');
}
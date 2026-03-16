{ pkgs, lib, isDesktop, sys, ... }:

let 
  systempkgs = [
    # systempkgs both desktop and server use
  ] ++ lib.optionals isDesktop [
    { 
      pkg = "wechat"; 
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"; 
    }
  ];
  pkgStrings = lib.concatMapStringsSep " " (obj: "\"${obj.pkg}|${obj.url}\"") systempkgs;
in
{
  home.activation.installNetworkSystemPkgs = lib.mkIf isDesktop (sys.task.root {
    name = "network-pkgs";
    pre = ''
      RAW_PKGS=(${pkgStrings})
      DOWNLOAD_LIST=""
      MISSING_NET_PKGS=""
      log_debug "configured platform.pkgManager='${sys.platform.pkgManager}'"
    '';
    script = ''
      PKG_MANAGER="$(detect_pkg_manager)"
      log_debug "detected package manager: $PKG_MANAGER"
      log_debug "total managed network packages: ''${#RAW_PKGS[@]}"

      if [ "$PKG_MANAGER" != "apt" ]; then
        log_warn "skip: current manager '$PKG_MANAGER' does not support .deb workflow"
      else
        if [ ''${#RAW_PKGS[@]} -gt 0 ]; then
          TEMP_DIR=$(mktemp -d)

          for item in "''${RAW_PKGS[@]}"; do
            PKG=''${item%%|*}
            URL=''${item#*|}
            if ! pkg_installed "$PKG"; then
              log_warn "'$PKG' not found, preparing download from $URL"
              MISSING_NET_PKGS="$MISSING_NET_PKGS $PKG"
              filename=$(basename "$URL")
              target="$TEMP_DIR/$filename"
              ${pkgs.curl}/bin/curl -L "$URL" -o "$target"
              DOWNLOAD_LIST="$DOWNLOAD_LIST $target"
            else
              log_info "'$PKG' already installed, skip."
            fi
          done

          if [ -n "$MISSING_NET_PKGS" ]; then
            log_error "missing network packages:$MISSING_NET_PKGS"
          else
            log_info "all network packages satisfied, nothing to install."
          fi

          if [ -n "$DOWNLOAD_LIST" ]; then
            pkg_update || true
            pkg_install_files $DOWNLOAD_LIST
          fi

          rm -rf "$TEMP_DIR"
        fi
      fi
    '';
  });
}
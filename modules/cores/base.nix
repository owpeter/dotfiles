###################################
#
#
#   BASE PACKAGES FOR MYSYSTEM
#
#
###################################

{ pkgs, config, secrets, lib, isDesktop, aLib, ... }:

{
    home.packages = with pkgs; [
    # base
    git 
    tmux
    systemd

    # crypt
    git-crypt
    gnupg

    # network
    curl 
    wget 

    # system
    btop 
    htop
    
    # tools
    unzip 
    jq 

    # opt 
    fzf 
    ripgrep 
    bat
    tree
    chsrc
  ] ++ lib.optionals isDesktop (with pkgs; [

    # desktop
    xclip
    xsel
  ]);

  home.file.".config/nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.file.".config/nix/nix.conf".text = ''
    substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
  '';

  home.activation.setupNixConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${aLib.initSudoPwd}
    ${aLib.esudoFn}
    CONTENT="trusted-users = root ${secrets.home.user}"
    if [ -z $DRY_RUN_CMD ]; then
      if ${pkgs.gnugrep}/bin/grep -qF "$CONTENT" /etc/nix/nix.custom.conf; then
        echo "Content already exists in /etc/nix/nix.custom.conf"
      else
        esudo ${aLib.cmds.sh} -c "echo '$CONTENT' >> /etc/nix/nix.custom.conf"
        esudo ${aLib.cmds.systemctl} restart nix-daemon
      fi
    fi
  '';
}
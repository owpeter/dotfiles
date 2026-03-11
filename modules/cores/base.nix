###################################
#
#
#   BASE PACKAGES FOR MYSYSTEM
#
#
###################################

{ pkgs, config, secrets, lib, ... }: 

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
    xclip 
    xsel
    cifs-utils
    
    # opt 
    fzf 
    ripgrep 
    bat
    tree
    chsrc
  ];

  home.file.".config/nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.file.".config/nix/nix.conf".text = ''
    substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
  '';

  home.activation.setupNixConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
    CONTENT="trusted-users = root ${secrets.home.user}"

    HOST_SUDO="/usr/bin/sudo"
    HOST_SYSTEMCTL="/usr/bin/systemctl"
    HOST_SH="/bin/sh"
    if [ -z $DRY_RUN_CMD ]; then
      if ${pkgs.gnugrep}/bin/grep -qF "$CONTENT" /etc/nix/nix.custom.conf; then
        echo "Content already exists in /etc/nix/nix.custom.conf"
      else
        echo "$SUDO_PWD" | $HOST_SUDO -S $HOST_SH -c "echo '$CONTENT' >> /etc/nix/nix.custom.conf"        
        echo $SUDO_PWD | $HOST_SUDO -S $HOST_SYSTEMCTL restart nix-daemon
      fi
    fi
  '';
}
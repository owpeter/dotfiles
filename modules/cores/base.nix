###################################
#
#
#   BASE PACKAGES FOR MYSYSTEM
#
#
###################################

{ pkgs, config, ... }: 

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
}
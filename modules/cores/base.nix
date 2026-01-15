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
    
    # opt 
    fzf 
    ripgrep 
    bat
    tree
  ];
}
{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # utils
    copyq

    # apps
    kdePackages.okular
    pavucontrol
    wechat
    google-chrome
    snipaste

    # patches
    libcanberra-gtk3
    mesa
  ];

  xdg.autostart.entries = {
    "wechat" = {
      enable = true;
      package = pkgs.wechat;
    };
    "snipaste" = {
      enable = true;
      package = pkgs.snipaste;
    };
  };

}
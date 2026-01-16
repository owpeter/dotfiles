{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    kdePackages.okular
    copyq
    pavucontrol
    wechat
    google-chrome
    snipaste
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
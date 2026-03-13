{ pkgs, config, ... }:

let

in
{
  home.packages = with pkgs; [
    # utils
    copyq
    slurp
    grim
    swappy
    nixgl.auto.nixGLDefault

    # apps
    kdePackages.okular
    pavucontrol
    feishu
    wemeet
    todesk
    google-chrome
    wpsoffice-cn

    # patches
    libcanberra-gtk3
    mesa
  ];

  xdg.autostart.enable = true;
  xdg.desktopEntries = {
    wechat = {
      name = "WeChat";
      comment = "WeChat Desktop App";
      exec = "usr/bin/wechat";
      icon = "wechat"; 
      terminal = false;
      categories = [ "Utility" ];
    };
  };
}

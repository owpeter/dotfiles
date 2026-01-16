{ pkgs, config, ... }:

let
  snipasteDesktop = pkgs.makeDesktopItem {
    name = "snipaste";
    desktopName = "Snipaste";
    comment = "Snipaste Screenshot Tool";
    exec = "${pkgs.snipaste}/bin/snipaste";
    icon = "snipaste";
    terminal = false;
    categories = [ "Utility" "Graphics" ];
    startupNotify = true; 
  };

in
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

  xdg.autostart.enable = true;
  xdg.desktopEntries = {
    snipaste = {
      name = "Snipaste";
      comment = "Snipaste Screenshot Tool";
      exec = "${pkgs.snipaste}/bin/snipaste";
      icon = "snipaste"; 
      terminal = false;
      categories = [ "Utility" ];
    };
  };

  xdg.autostart.entries = [
    "${pkgs.wechat}/share/applications/wechat.desktop"
    "${snipasteDesktop}/share/applications/snipaste.desktop"
  ];
}
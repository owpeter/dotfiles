{ pkgs, config, ... }:

let

in
{
  home.packages = with pkgs; [
    # utils
    copyq
    ksnip

    # apps
    kdePackages.okular
    pavucontrol
    wechat
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
  xdg.autostart.entries = [
    "${pkgs.wechat}/share/applications/wechat.desktop"
  ];
}
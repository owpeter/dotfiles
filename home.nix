{ config, pkgs, lib, secrets, ... }:

let 
  isDesktop = (secrets.home.option or "desktop") == "desktop";
in
{
  imports = [
    ./modules/cores
    ./modules/devps
    ./modules/libs
  ] ++ lib.optionals isDesktop [
    ./modules/desktops
  ];
  config = {
    home.username = secrets.home.user;
    home.homeDirectory = secrets.home.dir;
    home.stateVersion = "25.11";
    home.pointerCursor = lib.mkIf isDesktop {
      name = "Yaru";
      package = pkgs.yaru-theme;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
    };
    _module.args.isDesktop = isDesktop;
    programs.home-manager.enable = true;
  };
}
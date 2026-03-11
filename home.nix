{ config, pkgs, ... }:

let 
  path = builtins.getEnv "HOME";
  secretsPath = path + "/.config/dotfiles/secrets.nix";
  secrets =
    if builtins.pathExists (secretsPath)
    then import (secretsPath)
    else {};
in
{
  imports = [
    ./modules/cores
    ./modules/desktops
    ./modules/devps
  ];
  config = {
    home.username = secrets.home.user;
    home.homeDirectory = secrets.home.dir;
    home.stateVersion = "25.11";
    home.pointerCursor = {
      name = "Yaru";
      package = pkgs.yaru-theme;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
    _module.args.secrets = secrets;
    programs.home-manager.enable = true;
  };
}
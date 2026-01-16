{ config, pkgs, secrets, ... }:

{
  imports = [
    ./modules/cores
    ./modules/desktops
    ./modules/devps
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
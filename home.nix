{ config, pkgs, secrets, ... }:

{
  imports = [
    ./modules/cores
    ./modules/desktops
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}
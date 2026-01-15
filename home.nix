{ config, pkgs, ... }:

{
  imports = [
    ./modules/cores
  ];

  home.username = "chi";
  home.homeDirectory = "/home/chi";

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}
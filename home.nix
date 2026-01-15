{ config, pkgs, ... }:

{
  imports = [
    ./modules/core.nix
  ];

  home.username = "chi";
  home.homeDirectory = "/home/chi";

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}
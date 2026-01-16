{ config, pkgs, secrets, ... }:

{
  imports = [
    ./modules/cores
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}
{ config, pkgs, ... }:

{
  imports = [
    ./apt.nix
  ];
  home.packages = with pkgs; [
    (pkgs.callPackage ./tod.nix {}) 
  ];
}
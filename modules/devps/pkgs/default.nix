{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (pkgs.callPackage ./tod.nix {}) 
  ];
}
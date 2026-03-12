{ config, pkgs, ... }:

{
  imports = [
    ./apt.nix
    ./net-apt.nix
  ];
  home.packages = with pkgs; [
    (pkgs.callPackage ./tod.nix {}) 
  ];
}
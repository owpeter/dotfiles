{ config, pkgs, ... }:

{
  imports = [
    ./pkg.nix
    ./net-pkg.nix
  ];
  home.packages = with pkgs; [
    (pkgs.callPackage ./tod.nix {}) 
  ];
}
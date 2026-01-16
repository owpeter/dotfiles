{ lib, ... }:
{
  imports = [
    ./base.nix
    ./fcitx.nix
    ./rime.nix
    ./font.nix
    ./gnome.nix
    ./terminal.nix
  ];
}
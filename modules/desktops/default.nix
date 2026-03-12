{ lib, secrets, ... }:
let
  desktop = secrets.home.desktop or "all";
in
{
  imports = [
    ./base.nix
    ./fcitx.nix
    ./rime.nix
    ./font.nix
    ./terminal.nix
    ./sunshine.nix
  ]
  ++ lib.optionals (desktop == "gnome" || desktop == "all") [
    ./gnome.nix
  ]
  ++ lib.optionals (desktop == "niri" || desktop == "all") [
    ./niri.nix
  ];
}
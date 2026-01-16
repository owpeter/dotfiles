{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  imports = [
    ../../home.nix
  ];

  config = {
    home.username = "chi";
    home.homeDirectory = "/home/chi";
    _module.args.secrets = secrets;
  };
}
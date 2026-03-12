{
  description = "Chi's Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ nixgl.overlay ];
      };
      path = builtins.getEnv "HOME";
      secretsPath = path + "/.config/dotfiles/secrets.nix";
      secrets =
        if builtins.pathExists (secretsPath)
        then import (secretsPath)
        else {};
    in
    {
      homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit secrets; };
        modules = [ ./home.nix ];
      };
    };
}
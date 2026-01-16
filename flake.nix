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
      mkHome = user: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [
          ./hosts/${user}/default.nix
        ];
      };
    in
    {
      homeConfigurations = {
        "chi" = mkHome "chi";
      };
    };
}
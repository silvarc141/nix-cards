{
  description = "Squib and other card game making utils";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nix-utils.url = "github:silvarc141/nix-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nix-utils,
    ...
  }: let
    inherit (nixpkgs.lib) genAttrs;
    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    legacyPackages = genAttrs allSystems (system: import ./pkgs {
        pkgs = nixpkgs.legacyPackages.${system};
        utils = nix-utils.${system}.legacyPackages.lib;
      });
    formatter = genAttrs allSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    defaultPackage = genAttrs allSystems (system: self.legacyPackages.${system}.cards.todo);
  in {inherit formatter legacyPackages defaultPackage;};
}

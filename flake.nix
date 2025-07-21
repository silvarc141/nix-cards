{
  description = "Squib and other card game making utils";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nix-utils = {
      url = "github:silvarc141/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    legacyPackages = genAttrs allSystems (system:
      import ./pkgs {
        pkgs = nixpkgs.legacyPackages.${system};
        pkgsSelf = self.legacyPackages.${system};
        utils = nix-utils.legacyPackages.${system};
      });
    formatter = genAttrs allSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    defaultPackage = genAttrs allSystems (system: self.legacyPackages.${system}.squib-environment);
  in {inherit formatter legacyPackages defaultPackage;};
}

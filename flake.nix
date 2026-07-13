{
  description = "Squib and other card game making utils";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-utils = {
      url = "github:silvarc141/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    squib-src = {
      url = "github:silvarc141/squib";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-utils,
      squib-src,
      ...
    }:
    let
      inherit (nixpkgs.lib) genAttrs;
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      legacyPackages = genAttrs allSystems (
        system:
        import ./pkgs {
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsSelf = self.legacyPackages.${system};
          utils = nix-utils.legacyPackages.${system};
          inherit squib-src;
        }
      );
      checks = genAttrs allSystems (
        system:
        import ./checks.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsSelf = self.legacyPackages.${system};
        }
      );
      formatter = genAttrs allSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      packages = genAttrs allSystems (system: {
        default = self.legacyPackages.${system}.ruby-squib-env;
      });
    in
    {
      inherit
        formatter
        legacyPackages
        packages
        checks
        ;
    };
}

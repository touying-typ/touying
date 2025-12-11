{
  description = "Touying - Typst presentation slides package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tytanic = {
      url = "github:typst-community/tytanic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      tytanic,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.typst
            tytanic.packages.${system}.default
          ];

          shellHook = ''
            echo "Touying development shell"
            echo "  typst: $(typst --version)"
            echo "  tytanic: $(tt --version)"
          '';
        };
      }
    );
}

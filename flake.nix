{
  description = "Sync with git and rebuild";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixosPath.default = "~/my-nixos"
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages = {
      x86_64-linux = {
        my-nix-rebuild = pkgs.writeShellScriptBin "my-nix-rebuild" ''
          #!/usr/bin/env bash

          # Usage: ./update-and-commit.sh <label>

          LABEL=$1

          if [ -z "$LABEL" ]; then
            echo "You must specify a label!"
            exit 1
          fi
          
          set -e

          cd $nixosPath
          git commit -a -m "$LABEL"
          git push
          sudo NIXOS_LABEL="$LABEL" nixos-rebuild switch --flake $nixosPath
        '';
      };
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-command;
  };
}


{
  description = "Sync with git and rebuild";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages = {
      x86_64-linux = {
        my-nix-rebuild = pkgs.writeShellScriptBin "my-nix-rebuild" ''
          #!/usr/bin/env bash

          # Usage: ./update-and-commit.sh <path> <label>

          NIXOS_PATH=$1          

          if [ -z "$NIXOS_PATH" ]; then
            echo "You must specify a path!"
            exit 1
          fi

          LABEL=$2

          if [ -z "$LABEL" ]; then
            echo "You must specify a label!"
            exit 1
          fi
          
          set -e

          echo ">>>" $LABEL "<<<"

          cd $NIXOS_PATH
          git commit -a -m "$LABEL"
          git push
          sudo NIXOS_LABEL="$LABEL" nixos-rebuild switch --impure --flake $NIXOS_PATH
        '';
      };
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-command;
  };
}


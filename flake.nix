{
  description = "Sync with git and rebuild";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, nixosPath }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages = {
      x86_64-linux = {
        my-command = pkgs.writeShellScriptBin "my-command" ''
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


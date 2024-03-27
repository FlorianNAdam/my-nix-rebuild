{
  description = "Sync with git and rebuild";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
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

            # create bootloader compatible label
            SANITIZED_LABEL=$(echo "$LABEL" | sed 's/ /_/g' | sed 's/[^a-zA-Z0-9:_\.-]//g')

            # check if rebuild will work
            sudo NIXOS_LABEL="$SANITIZED_LABEL" nixos-rebuild dry-activate --impure --flake $NIXOS_PATH

            # sync git repo
            cd $NIXOS_PATH
            git commit -a -m "$LABEL"
            git push

            # rebuild system
            sudo NIXOS_LABEL="$SANITIZED_LABEL" nixos-rebuild switch --impure --flake $NIXOS_PATH
          '';
        };
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.my-nix-rebuild;
    };
}


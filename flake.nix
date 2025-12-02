{
  description = "A flake to develop python applications in.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        isDarwin = pkgs.stdenv.isDarwin;
        isLinux = pkgs.stdenv.isLinux;

        commonPackages =
          with pkgs;
          [
            python313
            figlet
          ]
          ++ (
            with pkgs;
            pkgs.lib.optionals isLinux [
              gcc
              stdenv.cc.cc.lib
            ]
          );

        runScript = pkgs.writeShellScriptBin "run-script" ''
          #!/usr/bin/env bash

          # Create a fancy welcome message
          REPO_NAME=$(basename "$PWD")
          PROPER_REPO_NAME=$(echo "$REPO_NAME" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
          figlet "$PROPER_REPO_NAME"
          echo "Welcome to the $PROPER_REPO_NAME development environment on ${system}!"
          echo
        '';

        # Base shell hook that just sets up the environment without any output
        baseEnvSetup = pkgs: ''
          # Set up the Python virtual environment with uv
          # export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath commonPackages}:$LD_LIBRARY_PATH
        '';

        mkLinuxShells = pkgs: {
          default = pkgs.mkShell {
            buildInputs = commonPackages;
            shellHook = ''
              ${baseEnvSetup pkgs}
              ${runScript}/bin/run-script
            '';
          };
        };

        mkDarwinShells = pkgs: {
          default = pkgs.mkShell {
            buildInputs = commonPackages;
            shellHook = ''
              ${baseEnvSetup pkgs}
              ${runScript}/bin/run-script
            '';
          };
        };

        shells = if isLinux then mkLinuxShells pkgs else mkDarwinShells pkgs;

      in
      {
        devShells = shells;
        devShell = shells.default;
      }
    );
}

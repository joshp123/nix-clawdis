{
  description = "nix-clawdbot: declarative Clawdbot packaging for macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }:
    let
      overlay = import ./nix/overlay.nix;
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          clawdbot-gateway = pkgs.clawdbot-gateway;
          clawdbot-app = pkgs.clawdbot-app;
          clawdbot = pkgs.clawdbot;
          clawdbot-docker = (import ./nix/images/clawdbot-docker.nix { inherit pkgs; }).image;
          clawdbot-docker-stream = (import ./nix/images/clawdbot-docker.nix { inherit pkgs; }).stream;
          clawdbot-tools-base = pkgs.clawdbot-tools-base;
          clawdbot-tools-extended = pkgs.clawdbot-tools-extended;
          default = pkgs.clawdbot;
        };

        apps = {
          clawdbot = flake-utils.lib.mkApp { drv = pkgs.clawdbot-gateway; };
        };

        checks = pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          gateway = pkgs.clawdbot-gateway;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.git
            pkgs.nixfmt-rfc-style
            pkgs.nil
          ];
        };
      }
    ) // {
      overlays.default = overlay;
      homeManagerModules.clawdbot = import ./nix/modules/home-manager/clawdbot.nix;
      darwinModules.clawdbot = import ./nix/modules/darwin/clawdbot.nix;

      templates = {
        agent-first = {
          path = ./templates/agent-first;
          description = "Agent-first template for clawdbot";
        };
      };
    };
}

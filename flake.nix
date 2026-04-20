{
  description = "Declarating... Imperative machines...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      sops-nix,
      ...
    }:
    let
      stVersion = "26.05";
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./Hosts)
      );
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.hjem.nixosModules.default
            sops-nix.nixosModules.sops
            ./Hosts/${hostname}
            (
              { config, ... }:

              let
                user = config.core.user;
              in

              {
                networking.hostName = hostname;
                system.stateVersion = stVersion;
                sops.defaultSopsFile = ./secrets.yaml;
                hjem.users.${user} = {
                  enable = true;
                  clobberFiles = true;
                };
              }
            )
          ];
        }
      );
    };
}

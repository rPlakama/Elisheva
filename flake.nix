{
  description = "Declarating... Imperative machines...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dms.url = "github:AvengeMedia/DankMaterialShell/";

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      sops-nix,
      home-manager,
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
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./Hosts/${hostname}
            (
              { config, ... }:
              {
                networking.hostName = hostname;
                system.stateVersion = stVersion;
                sops.defaultSopsFile = ./secrets.yaml;

                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs; };
                  users.${config.core.user}.home.stateVersion = stVersion;

                };
              }
            )
          ];
        }
      );
    };
}

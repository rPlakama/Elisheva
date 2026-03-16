{
  description = "Elisheva";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      sops-nix,
      niri,
      ...
    }:
    let
      system = "x86_64-linux";
      mkHost =
        {
          hostname,
          isDesktop ? true,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs isDesktop; };
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./shared.nix
            ./Config
            ./hardwares/${hostname}-hardware.nix
            { networking.hostName = hostname; }
            (
              { isDesktop, ... }:

              {
                system.stateVersion = "25.05";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs isDesktop; };
                  users.rplakama = import ./Config/home-manager/home.nix;
                };
              }
            )
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        "Elisheva" = mkHost {
          hostname = "Elisheva";
          isDesktop = true;
          extraModules = [
            niri.nixosModules.niri
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };

        "Centuria" = mkHost {
          hostname = "Centuria";
          isDesktop = true;
          extraModules = [
            niri.nixosModules.niri
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };

        "Moontier" = mkHost {
          hostname = "Moontier";
          isDesktop = false;
          extraModules = [ ];
        };
      };
    };
}

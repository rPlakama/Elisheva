{
  description = "Elisheva-OS";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    affinity-nix.url = "github:mrshmllow/affinity-nix";
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
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      niri,
      sops-nix,
      ...
    }:
    let
      sharedModules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./shared.nix
        ./Config
        (
          { isDesktop, ... }:
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs isDesktop; };
              users.rplakama = import ./Config/home-manager/home.nix;
            };
          }
        )
      ];
    in
    {
      nixosConfigurations = {

        "Elisheva" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isDesktop = true;
          };
          modules = sharedModules ++ [
            niri.nixosModules.niri
            ./Elisheva.nix
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };

        "Centuria" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isDesktop = true;
          };
          modules = sharedModules ++ [
            niri.nixosModules.niri
            ./Centuria.nix
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };

        "Moontier" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isDesktop = false;
          };
          modules = sharedModules ++ [
            ./Moontier.nix
          ];
        };
      };
    };
}

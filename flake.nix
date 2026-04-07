{
  description = "Something here should... be written?";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    niri = {
      url = "github:sodiboo/niri-flake";
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
      lib = nixpkgs.lib;
      mkHost =
        {
          hostname,
          extraModules ? [ ],
        }:
        let
          isCenturia = hostname == "Centuria";
          isElisheva = hostname == "Elisheva";
          isMoontier = hostname == "Moontier";
          isSunshir = hostname == "Sunshir";
          isDesktop = hostname != "Moontier";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              isCenturia
              isMoontier
              isElisheva
              isDesktop
              ;
          };
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./services
            ./system
            ./executables
            ./pkgs/shared-pkgs.nix
            ./pkgs/${hostname}-pkgs.nix
            ./hosts/${hostname}-hardware.nix
            {
              networking.hostName = hostname;
              system.stateVersion = "25.05";
              sops.defaultSopsFile = ./secrets.yaml;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit
                    inputs
                    hostname
                    isElisheva
                    isMoontier
                    isCenturia
                    isDesktop
                    ;
                };
                users.rplakama = import ./home-manager/home.nix;
              };
            }
          ]
          ++ lib.optionals isDesktop [
            ./pkgs/desktop-pkgs.nix
            ./system/desktop-boot.nix
            ./system/desktop-hardware.nix
            ./services/Desktop-services.nix
            ./executables/graphical.nix
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        "Elisheva" = mkHost {
          hostname = "Elisheva";
          extraModules = [
            niri.nixosModules.niri
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };
        "Centuria" = mkHost {
          hostname = "Centuria";
          extraModules = [
            niri.nixosModules.niri
            ./system/Centuria-hardware.nix
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };
        "Moontier" = mkHost {
          hostname = "Moontier";
          extraModules = [
            ./system/Moontier-hardware.nix
            ./services/Moontier-services
          ];
        };
      };
    };
}

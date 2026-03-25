{
  description = "Nix_OS. <3 <3 Cho-cho!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    dms.url = "github:AvengeMedia/DankMaterialShell/";
    home-manager.url = "github:nix-community/home-manager";
    niri.url = "github:sodiboo/niri-flake";
    danksearch.url = "github:AvengeMedia/danksearch";
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
          extraModules ? [ ],
        }:
        let
          isCenturia = hostname == "Centuria";
          isElisheva = hostname == "Elisheva";
          isMoontier = hostname == "Moontier";
          isDesktop = hostname != "Moontier";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit
              inputs
              isCenturia
              isElisheva
              isMoontier
              isDesktop
              ;
          };

          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./Config
            ./hardwares/${hostname}-hardware.nix

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
                users.rplakama = import ./Config/home-manager/home.nix;
              };
            }
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
            { nixpkgs.overlays = [ niri.overlays.niri ]; }
          ];
        };

        "Moontier" = mkHost {
          hostname = "Moontier";
          extraModules = [
            ./Moontier
          ];
        };
      };
    };
}

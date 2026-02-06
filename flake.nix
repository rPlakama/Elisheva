{
  description = "Elisheva-OS";
  inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
  };

  outputs =
    {
      sops-nix,
      nixpkgs,
      home-manager,
      niri,
      ...
    }@inputs:
    {
      nixosConfigurations."Elisheva" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          niri.nixosModules.niri
          sops-nix.nixosModules.sops
          {
            nixpkgs.overlays = [ niri.overlays.niri ];
          }
          ./Elisheva.nix
          ./Config
          ./shared.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
            };
            home-manager.users.rplakama = {
              imports = [
                ./Config/home-manager/home.nix
              ];
            };
          }
        ];
      };
      nixosConfigurations."Centuria" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          niri.nixosModules.niri
          ./Config
          ./shared.nix
          ./Centuria.nix
          {
            nixpkgs.overlays = [ niri.overlays.niri ];
          }
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
            };

            home-manager.users.rplakama = {
              imports = [
                ./Config/home-manager/home.nix
              ];
            };
          }
        ];
      };

      nixosConfigurations."Moontier" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./Moontier
          ./shared.nix
          ./Config
          ./Moontier.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
            };
            home-manager.users.rplakama = {
              imports = [
                ./Config/home-manager/home.nix
              ];
            };
          }
        ];
      };
    };
}

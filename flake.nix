{
  description = "Elisheva-OS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:
    {
      nixosConfigurations."Elisheva" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
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
          nixos-hardware.nixosModules.gigabyte-b550
          ./Config
          ./shared.nix
          ./Centuria.nix
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

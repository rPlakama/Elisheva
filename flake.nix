{
  description = "Elisheva-OS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

   impermanence = {
     url = "github:nix-community/impermanence";
     inputs.nixpkgs.follows = "nixpkgs";
   };
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
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
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      niri,
      home-manager,
      impermanence,
      stylix,
      ...
    }@inputs:
    {
      nixosConfigurations."Elisheva" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          stylix.nixosModules.stylix
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          niri.nixosModules.niri
          {
            nixpkgs.overlays = [ niri.overlays.niri ];
          }
          ./Elisheva.nix
          ./Config
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
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          niri.nixosModules.niri
          impermanence.nixosModules.impermanence
          {
            nixpkgs.overlays = [ niri.overlays.niri ];
          }
          ./Config
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
    };
}

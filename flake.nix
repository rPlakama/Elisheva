{
  description = "SharkGirls are Cool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms.url = "github:AvengeMedia/DankMaterialShell/b036da2446944eb51d460d572a36f2237e72ac26";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = {
    nixpkgs,
    niri,
    home-manager,
    stylix,
    nix-flatpak,
    ...
  } @ inputs: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    nixosConfigurations."Elisheva" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        niri.nixosModules.niri
        {
          nixpkgs.overlays = [niri.overlays.niri];
        }
        ./Elisheva.nix
        ./Shared
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs;};
          };

          home-manager.users.rplakama = {
            imports = [
              ./Shared/home.nix
              ./Elisheva/config/niri/default.nix
            ];
          };
        }
      ];
    };
    nixosConfigurations."Centuria" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        stylix.nixosModules.stylix
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        niri.nixosModules.niri
        {
          nixpkgs.overlays = [niri.overlays.niri];
        }
        ./Centuria.nix
        ./Shared
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs;};
          };

          home-manager.users.rplakama = {
            imports = [
              ./Shared/home.nix
            ];
          };
        }
      ];
    };
  };
}

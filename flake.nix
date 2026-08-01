{
  description = "Declarating... Imperative machines...";

  inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    twatch.url = "github:rPlakama/twatch";
    kavita-pkg.url = "github:rPlakama/Kavita-flake";
    gsr-ui-nix.url = "github:rPlakama/gsr-ui-nix";
    helium-browser.url = "github:schembriaiden/helium-browser-nix-flake";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    preservation.url = "github:nix-community/preservation";

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      sops-nix,
      disko,
      preservation,
      ...
    }:
    let
      stVersion = "26.05";
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./Hosts)
      );
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsM = import inputs.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
      };

    in
    {

      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs pkgsM; };
          modules = [
            inputs.hjem.nixosModules.default
            inputs.nixvim.nixosModules.nixvim
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            preservation.nixosModules.default
            ./Hosts/${hostname}
            (
              {
                lib,
                config,
                ...
              }:
              let
                user = config.core.user;
              in
              {

                options.core = {
                  host = lib.mkOption {
                    type = lib.types.str;
                    description = "Hostname option explicity";
                    default = "${hostname}";
                    readOnly = true;
                  };
                };

                config = {
                  nix.settings = {
                    substituters = [ "https://attic.xuyh0120.win/lantian" ];
                    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
                  };

                  networking.hostName = hostname;
                  system.stateVersion = stVersion;
                  sops.defaultSopsFile = ./secrets.yaml;
                  hjem.users.${user} = {
                    enable = true;
                    clobberFiles = true;
                  };
                };
              }
            )
          ];
        }
      );

      # Devshell
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            python314
            ruff
          ];
        };
      };
    };
}

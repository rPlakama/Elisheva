{
  description = "Declarating... Imperative machines...";

  inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musika.url = "github:rPlakama/musika";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-craftapps = {
      url = "github:olafkfreund/nix-craftapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
    twatch.url = "github:rPlakama/twatch";
    gsr-ui-nix.url = "github:rPlakama/gsr-ui-nix";
    helium-browser.url = "github:schembriaiden/helium-browser-nix-flake";
    umbriel.url = "git+https://github.com/noctalia-dev/umbriel";
    zapfast.url = "github:crmne/zapfast";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/26.05"; # Latest stable

    dms.url = "github:AvengeMedia/DankMaterialShell";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    preservation.url = "github:nix-community/preservation";

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      sops-nix,
      disko,
      preservation,
      chaotic,
      ...
    }:
    let
      stVersion = "26.05";
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./Hosts)
      );
      system = "x86_64-linux";

      pkgsS = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      pkgsM = import inputs.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs pkgsM pkgsS; };
          modules = [
            inputs.hjem.nixosModules.default
            sops-nix.nixosModules.sops
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
    };
}

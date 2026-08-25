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
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    twatch.url = "github:rPlakama/twatch";
    gsr-ui-nix.url = "github:rPlakama/gsr-ui-nix";
    helium-browser.url = "github:schembriaiden/helium-browser-nix-flake";
    umbriel.url = "git+https://github.com/noctalia-dev/umbriel";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
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
      auto-cpufreq,
      chaotic,
      ...
    }:
    let
      stVersion = "26.05";
      hostNames = builtins.attrNames (
        nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./Hosts)
      );
      system = "x86_64-linux";
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
    };
}

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
    preservation.url = "github:nix-community/preservation";

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
  };

  outputs =
    inputs@{
      nix-cachyos-kernel,
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
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames (
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.hjem.nixosModules.default
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
                  nixpkgs.overlays = [
                    nix-cachyos-kernel.overlays.pinned
                    (final: prev: {
                      # Pin Komga to 1.24.3 — versions ≥1.24.4 omit ageRestriction
                      # from UserDto which breaks Komf 1.7.1 (see Komf issue #303)
                      komga = prev.komga.overrideAttrs (old: rec {
                        version = "1.24.3";
                        src = prev.fetchurl {
                          url = "https://github.com/gotson/komga/releases/download/${version}/komga-${version}.jar";
                          hash = "sha256-+MZ2Rr/QYJuKBZdQtuQaq1crRRqBPo3LGRHjkl1Gupo=";
                        };
                      });
                    })
                  ];

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

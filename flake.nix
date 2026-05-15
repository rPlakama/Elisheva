{
  description = "Declarating... Imperative machines...";

  inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };

    gsr-ui-nix.url = "github:rPlakama/gsr-ui-nix";
    kavita.url = "github:nevivurn/nixpkgs/update/kavita";

    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
  };

  outputs =
    inputs@{
      helium-flake,
      nix-cachyos-kernel,
      nixpkgs,
      sops-nix,
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
            ./Hosts/${hostname}
            (
              { config, ... }:

              let
                user = config.core.user;
              in

              {
                nixpkgs.overlays = [
                  helium-flake.overlays.default
                  nix-cachyos-kernel.overlays.pinned
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
              }
            )
          ];
        }
      );
    };
}

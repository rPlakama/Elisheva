{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.nix;
in

{
  options.features.nix.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Nix package manager configuration";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    nix = {
      package = pkgs.lix;
      settings = {
        show-trace = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "${config.core.user}"
          "networkmanager"
          "root"
          "@wheel"
        ];
      };
    };
  };
}
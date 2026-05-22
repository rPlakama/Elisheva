{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.core.features.nix;
in

{
  options.core.features.nix.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Nix package manager configuration";
    default = true;
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
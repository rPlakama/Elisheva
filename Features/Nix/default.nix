{ config, pkgs, ... }:

{

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
}

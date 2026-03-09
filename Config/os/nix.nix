{ pkgs, ... }:

{
  security.sudo-rs.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.lix;
  nix.settings = {
    trusted-users = [ "root" "rplakama" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
}


{ pkgs, ... }:
{
  nix.package = pkgs.lix;
  security.sudo-rs.enable = true;
}

{ pkgs, ... }:

{
  security.sudo-rs.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.lix;
  nix = {
    settings = {
      show-trace = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "networkmanager"
        "rplakama"
        "root"
        "@wheel"
      ];
    };
  };

}

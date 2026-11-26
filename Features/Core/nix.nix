{
  config,
  pkgs,
  ...
}:
let
  user = config.core.user;
  headless = config.core.headless;
in
{
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;
  nix = {
    package = pkgs.lix;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than +5d";
    };
    optimise = {
      automatic = headless;
      dates = [ "weekly" ];
    };
    settings = {
      auto-optimise-store = !headless;
      show-trace = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "flake-self-attrs"
      ];
      trusted-users = [
        "${user}"
        "networkmanager"
        "root"
        "@wheel"
      ];
    };
  };
}

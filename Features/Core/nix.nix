{
  config,
  pkgs,
  ...
}:
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
    settings = {
      auto-optimise-store = true;
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

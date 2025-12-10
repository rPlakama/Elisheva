{ ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      show-trace = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "networkmanager"
        "root"
        "@wheel"
      ];
    };
  };
}

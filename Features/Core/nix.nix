{
  config,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = lib.mkIf (config.core.cpu."micro-arch" != null) (lib.mkForce {
    system = "x86_64-linux";
    gcc.cpu = config.core.cpu."micro-arch";
  });
  programs.nix-ld.enable = true;
  nix = {
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

{ pkgs, ... }:

{
  # Myself
  users.users.rplakama = {
    isNormalUser = true;
    description = "rPlakama.";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
  #Which is I!
  boot = {
    initrd = {
      systemd.network.wait-online.enable = false;
      systemd.enable = true;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 0;
    };
  };
  # Therefore I am.
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

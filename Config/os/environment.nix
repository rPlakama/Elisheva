{
  isDesktop,
  isElisheva,
  lib,
  pkgs,
  ...
}:

{
  virtualisation.libvirtd.enable = isDesktop;
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

  console.keyMap = if isElisheva then "br-abnt" else "us";
  time.timeZone = "America/Recife";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  users.users.rplakama = {
    isNormalUser = true;
    description = "rPlakama.";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ]
    ++ lib.optionals isDesktop [
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MANPAGER = "nvim +Man!";
    };
    shellAliases = {
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}

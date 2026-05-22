{ pkgs, ... }:
{
  imports = [
    # ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Arthoplerau";
  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
    kernelParams = [ "amd_pstate=active" ]; # -- Useful.
  };

  hardware.bluetooth.enable = true;
  core.user = "rplakama";
  services.power-profiles-daemon.enable = true; # -- Only Arthoplerau uses it anyway
  optionals.features = {
    niri.enable = true;
    virtualization.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      flags = [
        "--performance" # Max computing when needed.
        "--autopoint" # Also manages itself for lower consume.
      ];
    };
    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme0n1"; # -- Placeholder
      secondaryDrive = "/dev/nvme1n1"; # -- Placeholder
    };
    preservation = {
      additionalHomeDirs = [
        ".config/vesktop" # -- Imma not doing it manually
        ".config/niri" # -- Cause 'dms generated files
      ];
    };
  };
}

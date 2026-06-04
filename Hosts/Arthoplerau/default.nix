{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../Features
    inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5

  ];

  environment.systemPackages = with pkgs; [
    ciscoPacketTracer9
  ];

  networking.hostName = "Arthoplerau";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  core = {
    user = "rplakama";
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  services.tlp.enable = false; # <- Declared in nixos-hardware
  features = {
    niri = {
      enable = true;
      NoctaliaEnabled = true;
    };
    steam.enable = true;
    virtualization.enable = true;
    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme1n1";
      secondaryDrive = "/dev/nvme0n1";
      swap.enable = true;
    };
    preservation = {
      enable = true;
      keepDirs.homeDirs = [ "pt" ];
    };
  };
}

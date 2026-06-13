{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  environment.systemPackages = with pkgs; [
    ciscoPacketTracer9
  ];

  networking.hostName = "Arthoplerau";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  core = {
    user = "rplakama";
    gpu.amd = true;
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };

  features = {
    niri = {
      enable = true;
      NoctaliaEnabled = true;
      ppd.enable = false;
    };
    gaming.enable = true;
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
      home.directories = [
        "pt"
      ];
    };
  };
}

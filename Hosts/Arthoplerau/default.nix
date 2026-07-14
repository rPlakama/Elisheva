{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../Features
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
    cpu.amd = true;
    isLaptop = true;
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };

  features = {
    niri = {
      enable = true;
      NoctaliaEnabled = true;
      output.vrr.enable = false;
    };

    gaming = {
      enable = true;
      gsr.enable = true;
    };

    qbit.enable = true;
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

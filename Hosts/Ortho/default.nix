{ ... }: {
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Ortho";
  # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;

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
      primaryDrive = "/dev/nvme0n1";
      # secondaryDrive = "/dev/nvme0n1";
      swap = {
        enable = true;
        # size = "4GB";
      };
    };
    preservation = {
      enable = true;
      home.directories = [
        "pt"
      ];
    };
  };
}

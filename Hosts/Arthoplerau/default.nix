{ ... }: {
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Arthoplerau";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  core = {
    user = "rplakama";
    gpu.amd = true;
    cpu.amd = true;
    zram.size = 8192;
    isLaptop = {
      enable = true;
      usesPPD = true;
    };
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };

  features = {
    neovim.enable = true;

    niri = {
      enable = true;
      noctalia.enabled = true;
      output.vrr.enable = true;
    };

    gaming = {
      enable = true;
      gsr.enable = true;
    };

    qbit.enable = true;
    virtualization.enable = true;
    ia-tools.enable = true;

    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme1n1";
      secondaryDrive = "/dev/nvme0n1";
      compression = "zstd:6";
      swap.enable = true;
    };

    preservation.enable = true;
  };
}

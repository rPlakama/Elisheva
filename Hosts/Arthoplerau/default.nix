{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./performance.nix
    ../../Features
  ];

  hardware.bluetooth = {
    enable = true;
  };

  core = {
    user = "rplakama";
    gpu.amd = true;
    cpu.amd = true;
    zram = {
      size = 8192;
      algorithm = "lz4";
    };
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

    # qbit.enable = true;
    syncthing.enable = true;
    virtualization.enable = true;
    ia-tools.enable = true;
    art-toolchain.enable = true;
    benchtools.enable = true;

    bluetooth-injct = {
      enable = true;
      deviceMac = "40:EB:98:20:53:65";
    };

    disko = {
      enable = true;
      dualDrive = true;
      primaryDrive = "/dev/nvme0n1";
      secondaryDrive = "/dev/nvme1n1";
      swap.enable = true;
      format.BTRFS = { };
      mode.normal = { };
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
    python3
  ];
}

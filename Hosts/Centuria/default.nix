{ ... }: {
  imports = [
    ./hardware.nix
    ./performance.nix
    ../../Features
  ];

  core = {

    keyboardLayout = "us,br";
    user = "rplakama";
    gpu.nvidia = true;
    cpu.amd = true;
    zram = {
      size = 8192;
      algorithm = "lz4";
    };
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  features = {
    neovim.enable = true;
    virtualization.enable = true;
    sunshine.enable = true;

    disko = {
      enable = true;
      primaryDrive = "/dev/nvme1n1";
      swap.enable = true;
      format.BTRFS = {
        compression = "zstd:3";
      };
      mode.impermanence = { };
    };

    preservation.enable = true;

    gaming = {
      enable = true;
      gsr.enable = true;
      triforce.enable = true;
    };
    # qbit.enable = true;
    bluetooth-injct = {
      enable = true;
      deviceMac = "40:EB:98:20:53:65";
      MSIB550Board = true;
    };
    syncthing.enable = true;
    # ia-tools.enable = true;
    art-toolchain.enable = true;
    niri = {
      enable = true;
      noctalia.enabled = true;
      output.vrr.enable = false;
    };
  };
}

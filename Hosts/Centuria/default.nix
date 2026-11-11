{ ... }: {
  imports = [
    ./hardware.nix
    ../../Features
  ];

  core = {

    keyboardLayout = "us,br";
    user = "rplakama";
    gpu.nvidia = true;
    cpu.amd = true;
    zram.size = 8192;
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
      isBTRFS = true;
      primaryDrive = "/dev/nvme1n1";
      btrfs.compression = "zstd:6";
      swap.enable = true;
    };

    preservation.enable = true;

    gaming = {
      enable = true;
      gsr.enable = true;
    };
    qbit.enable = true;
    syncthing.enable = true;
    ia-tools.enable = true;
    art-toolchain.enable = true;
    niri = {
      enable = true;
      noctalia.enabled = true;
      output.vrr.enable = false;
    };
  };
}

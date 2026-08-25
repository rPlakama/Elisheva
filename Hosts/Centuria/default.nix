{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ../../Features
  ];

  environment.systemPackages = with pkgs; [
    ckan
  ];
  core = {

    keyboardLayout = "br,us";
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
      primaryDrive = "/dev/nvme1n1";
      compression = "zstd:6";
      swap.enable = true;
    };

    preservation.enable = true;

    gaming = {
      enable = true;
      gsr.enable = true;
    };
    qbit.enable = true;
    niri = {
      enable = true;
      noctalia.enabled = true;
      output.vrr.enable = false;
    };
  };
}

{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  environment.systemPackages = with pkgs; [
    ckan
  ];
  core = {
    user = "rplakama";
    gpu.nvidia = true;
    cpu.amd = true;
    git = {
      email = "rPlakama@proton.me";
      user = "rPlakama";
    };
  };
  features = {
    virtualization.enable = true;
    sunshine.enable = true;
    gaming = {
      enable = true;
      gsr.enable = true;
    };
    qbit.enable = true;
    niri = {
      keyboardLayout = "br,us";
      enable = true;
      noctalia.enabled = true;
      output.vrr.enable = false;
    };
  };
}

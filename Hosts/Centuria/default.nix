{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  environment.systemPackages = with pkgs; [
    ckan
    ollama-cuda
    opencode
    btop-cuda
  ];
  core.user = "rplakama";
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
  optionals.features = {
    nvidia.enable = true;
    virtualization.enable = true;
    neovim.enable = true;
    sunshine.enable = true;
    steam.enable = true;
    qbit.enable = true;
    scx.enable = true;

    niri = {
      keyboardLayout = "br,us";
      enable = true;
    };

  };
}

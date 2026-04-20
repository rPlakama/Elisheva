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
  ];
  core = {
    user = "rplakama";
  };
  optionals.features = {
    nvidia.enable = true;
    niri.enable = true;
    virtualization.enable = true;
    neovim.enable = true;
    sunshine.enable = true;
    steam.enable = true;
    qbit.enable = true;
    scx.enable = true;
  };
}

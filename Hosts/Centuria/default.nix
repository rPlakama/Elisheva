{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  environment.systemPackages = [
    pkgs.ckan
  ];
  core = {
    user = "rplakama";
    nvidia.enable = true;
  };
  optionals.features = {
    niri.enable = true;
    neovim.enable = true;
    sunshine.enable = true;
    steam.enable = true;
    qbit.enable = true;
    scx.enable = true;
  };
}

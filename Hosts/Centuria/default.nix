{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  core = {
    user = "rplakama";
    nvidia.enable = true;
  };
  optionals.features = {
    niri.enable = true;
    neovim.enable = true;
    sunshine.enable = true;
    steam.enable = true;
  };
}

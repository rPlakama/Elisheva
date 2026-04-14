{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  core.user = "rplakama";
  optionals.features = {
    niri.enable = true;
    neovim.enable = true;
  };
}

{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Centuria";

  mySystem.user = "rplakama";
  mySystem.features = {
    niri.enable = true;
    neovim.enable = true;
  };
}

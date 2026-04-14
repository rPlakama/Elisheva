{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Elisheva";

  mySystem.user = "rplakama";
  mySystem.features = {
    niri.enable = true;
    neovim.enable = true;
  };
}

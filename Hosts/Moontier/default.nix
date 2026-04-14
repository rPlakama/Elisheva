{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Moontier";

  mySystem.user = "rplakama";
  mySystem.features = {
    niri.enable = true;
    neovim.enable = true;
  };
}

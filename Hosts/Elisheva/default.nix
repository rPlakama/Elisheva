{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Elisheva";

  core.user = "rplakama";
  optionals.features = {
    niri.enable = true;
    neovim.enable = true;
  };
}

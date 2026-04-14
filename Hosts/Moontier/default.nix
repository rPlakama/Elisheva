{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Moontier";

  core.user = "rplakama";
  optionals.features = {
    niri.enable = true;
    neovim.enable = true;
    graphicalPkgs.enable = false;
  };
}

{ ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Moontier";

  core.user = "rplakama";
  optionals.features = {
    niri.enable = false;
    neovim.enable = true;
    graphicalPkgs.enable = false;
    suwayomi.enable = false;
    komga.enable = true;
    pi-hole.enable = true;
    nzbget.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    whats_bot.enable = true;
    slskd.enable = true;
  };
}

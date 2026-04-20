{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Moontier";

  environment.systemPackages = with pkgs; [
    btop
  ];
  core.user = "rplakama";
  optionals.features = {
    niri.enable = false;
    neovim.enable = true;
    graphicalPkgs.enable = false;
    suwayomi.enable = true;
    komga.enable = true;
    pi-hole.enable = true;
    adguard.enable = false;
    nzbget.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    whats_bot.enable = true;
    slskd.enable = true;
    nginx.enable = true;
  };
}

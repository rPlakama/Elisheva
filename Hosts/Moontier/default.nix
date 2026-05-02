{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Moontier";

  environment.systemPackages = with pkgs; [
    btop
    exiftool
    calibre
    zip
  ];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server-lto;
  core.user = "rplakama";
  optionals.features = {
    niri.enable = false;
    neovim.enable = true;
    graphicalPkgs.enable = false;
    suwayomi.enable = true;
    komga.enable = true;
    kavita.enable = true;
    pi-hole.enable = true;
    nzbget.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    whats_bot.enable = true;
    slskd.enable = true;
    nginx.enable = true;
  };
}

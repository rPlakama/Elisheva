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
    neovim.enable = true;
    graphicalPkgs.enable = false;
    kavita.enable = true;
    pi-hole.enable = true;
    nzbget.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    whats_bot.enable = true;
    slskd.enable = true;
    nginx.enable = true;
    Samba.enable = true;
    galleryDl = {
      enable = true;
      urls = [
        "https://mangafire.to/manga/madan-no-ichii.w5x17"
        "https://mangafire.to/manga/centuriaa.zxvjp"
      ];
    };
  };
}

{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Moontier";

  environment.systemPackages = with pkgs; [
    btop
    exiftool
    smartmontools
    calibre
    zip
  ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server-lto;

  core.user = "rplakama";
  core.ip = "192.168.1.106";
  core.domain = "moontier.online";

  sops.secrets."gallery_dl_urls" = {
    owner = config.core.user;
  };

  optionals.features = {
    neovim.enable = true;
    graphicalPkgs.enable = false;
    unifiedDNS.enable = true;
    kavita.enable = true;
    nzbget.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    whats_bot.enable = true;
    slskd.enable = true;
    Samba.enable = true;
    homepage.enable = true;
    ST.enable = true;
    nextcloud.enable = true;
    iperf3.enable = true;
    jellyfin.enable = true;
    galleryDl = {
      enable = true;
      secretFile = config.sops.secrets."gallery_dl_urls".path;
    };
  };
}

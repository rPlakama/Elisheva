{ config, pkgs, ... }:

let
  cfgSops = config.sops.secrets;
in
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
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bmq-lto;

  core = {
    user = "rplakama";
    ip = "192.168.0.160";
    domain = "moontier.online";
  };
  features.graphicalPkgs.enable = false;

  sops.secrets = {
    "gallery-dl/ao3-username" = {
      owner = config.core.user;
    };
    "gallery-dl/ao3-password" = {
      owner = config.core.user;
    };
    "gallery-dl/mangas-urls" = {
      owner = config.core.user;
    };
    "gallery-dl/literature-urls" = {
      owner = config.core.user;
    };
  };

  features = {
    unifiedDNS = {
      enable = true;
      gateway = "192.168.0.1";
    };
    kavita.enable = true;
    nzbget.enable = true;
    rrstack.enable = true;
    qbit.enable = true;
    whatsBot.enable = true;
    slskd.enable = true;
    samba.enable = true;
    homepage.enable = true;
    st.enable = true;
    nextcloud.enable = true;
    iperf3.enable = true;
    jellyfin.enable = true;
    calibre.enable = true;
    navidrome.enable = true;
    galleryDL = {
      enable = true;
      mangas = {
        downloadPath = "/media/mangas/download";
        secretFile = cfgSops."gallery-dl/mangas-urls".path;
      };
      literature = {
        downloadPath = "/media/fanfics/download";
        secretFile = cfgSops."gallery-dl/literature-urls".path;
      };
    };
  };
}

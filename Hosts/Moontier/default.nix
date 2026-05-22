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
  core.features.graphicalPkgs.enable = false;

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

  optionals.features = {
    unifiedDNS.enable = true;
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
    galleryDL = {
      enable = true;
      mangas = {
        downloadPath = "/media/mangas/download";
        secretFile = config.sops.secrets."gallery-dl/mangas-urls".path;
      };
      literature = {
        downloadPath = "/media/fanfics/download";
        secretFile = config.sops.secrets."gallery-dl/literature-urls".path;
      };
    };
  };
}

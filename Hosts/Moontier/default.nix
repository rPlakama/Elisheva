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
      urls = [
        "https://mangafire.to/manga/madan-no-ichii.w5x17"
        "https://mangafire.to/manga/centuriaa.zxvjp"
        "https://mangafire.to/manga/gachiakutaa.1n2xq"
      ];
    };
  };
}

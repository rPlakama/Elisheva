{
  config,
  pkgs,
  ...
}: let
  peer-port = 51413;
  web-port = 3000;
  downloadDir = "${config.users.users.rtorrent.home}/Torrents";
in {
  users.users.rtorrent = {
    isSystemUser = true;
    group = "rtorrent";
    home = "/var/lib/rtorrent";
    createHome = true;
  };

  users.groups.rtorrent = {};

  systemd.tmpfiles.rules = [
    "d ${downloadDir} 0755 rtorrent rtorrent -"
  ];

  services.rtorrent = {
    enable = true;
    port = peer-port;
    package = pkgs.rtorrent;
    openFirewall = true;
    downloadDir = downloadDir;
  };

  services.flood = {
    enable = true;
    port = web-port;
    openFirewall = true;
    extraArgs = ["--rtsocket=${config.services.rtorrent.rpcSocket}"];
  };

  systemd.services.flood.serviceConfig.SupplementaryGroups = [
    config.services.rtorrent.group
  ];
}

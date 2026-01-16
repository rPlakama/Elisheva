{ pkgs, ... }:

{
  services.transmission = {
    enable = true;
    openFirewall = true;
    openRPCPort = true;
    group = "users";
    package = pkgs.transmission_4;
    webHome = pkgs.flood-for-transmission;

    settings = {
      download-dir = "/mnt/secondary/torrent";
      incomplete-dir-enabled = true;
      incomplete-dir = "/mnt/secondary/torrent/.incomplete";
      rpc-whitelist-enabled = false;
      speed-limit-up-enabled = false;
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
    };
  };

}

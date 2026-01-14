{ pkgs, ... }:
{

  services.transmission = {
    enable = true;
    openFirewall = true;

    package = pkgs.transmission_4;
    webHome = pkgs.flood-for-transmission;

    group = "users";

    settings = {
      download-dir = "/var/lib/transmission/Downloads";
      incomplete-dir = "/var/lib/transmission/.incomplete";
      incomplete-dir-enabled = true;

      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;

      umask = 2;

      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };
  };
}

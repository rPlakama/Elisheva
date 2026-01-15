{ pkgs, ... }:
{

  services.transmission = {
    enable = true;
    openFirewall = true;

    package = pkgs.transmission_4;
    webHome = pkgs.flood-for-transmission;

    group = "users";

    settings = {
      "incomplete-dir" = "/mnt/secondary/animes/.incomplete";
      "incomplete-dir-enabled" = true;
      "download-dir" = "/mnt/secondary/animes";

      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;

      umask = 2;

      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };
  };
}

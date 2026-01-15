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
      "download-dir" = "/mnt/secondary/animes";
      "incomplete-dir-enabled" = true;
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      umask = 2;
    };
  };
}

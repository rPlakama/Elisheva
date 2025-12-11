{ pkgs, ... }:
{
  services.transmission = {
    enable = true;
    openFirewall = true;

    package = with pkgs; transmission_4;
    webHome = with pkgs; flood-for-transmission;

    user = "rplakama";
    group = "users";
    settings = {
      download-dir = "/home/rplakama/Torrents/";
      peer-port = 51413;
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0";
    };
  };
}

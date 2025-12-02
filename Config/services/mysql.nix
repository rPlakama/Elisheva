{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.networking.hostName == "Elisheva") {
  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.samba;
  persistEnabled = config.optionals.features.preservation.enable;
in

{
  options.optionals.features.samba.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Samba, open my /media to network";
  };
  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "Moontier Media Server";
          "netbios name" = "moontier";
          "security" = "user";
          "hosts allow" = "192.168.1. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
        };

        "media" = {
          "path" = "/media";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force group" = "media";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    optionals.features.preservation.keepDirs.additionalDirs = lib.mkIf persistEnabled [
      "/var/lib/samba"
    ];
  };
}
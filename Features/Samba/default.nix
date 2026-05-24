{
  config,
  lib,
  ...
}:

let
  cfg = config.features.samba;
in

{
  options.features.samba.enable = lib.mkEnableOption "Samba file sharing";
  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "${config.networking.hostName} Media Server";
          "netbios name" = config.networking.hostName;
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
  };
}
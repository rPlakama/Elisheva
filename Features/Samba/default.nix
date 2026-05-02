{
  config,
  lib,
  ...
}:

{
  options.optionals.features.Samba.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Samba, open my /media to network";
  };
  config = lib.mkIf config.optionals.features.Samba.enable {
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
        #
        "media" = {
          "path" = "/media";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no"; # Requires login
          "create mask" = "0664";
          "directory mask" = "0775";
          "force group" = "media"; # Ensures media-stack can see it;
        };
      };
    };

    # Share also for Windows, might be useful;
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}

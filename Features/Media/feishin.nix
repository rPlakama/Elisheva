{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.feishin;
in {
  options.features.feishin = {
    enable = lib.mkEnableOption "Feishin selfhosted web music player";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.feishin-web;
      defaultText = lib.literalExpression "pkgs.feishin-web";
      description = "Feishin web package to serve";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9183;
      description = "Port to serve Feishin web on";
    };
  };

  config = lib.mkIf cfg.enable {
    features = {
      unifiedDNS.proxyServices.feishin = cfg.port;
      preservation.system.directories = [ "/var/lib/feishin" ];
    };

    systemd.services.feishin-web = {
      description = "Feishin Web Music Player";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.python3}/bin/python3 -m http.server ${toString cfg.port} --directory ${cfg.package}";
        User = "nobody";
        Group = "nogroup";
        Restart = "always";
        RestartSec = 5;
        NoNewPrivileges = true;
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  configSrc = toString (
    pkgs.writeText "sillytavern-config.yaml" ''
      listen: true
      listenAddress:
        ipv4: 127.0.0.1
        ipv6: '[::]'
      protocol:
        ipv4: true
        ipv6: false
      port: 6720
      whitelistMode: false
      securityOverride: true
      dataRoot: ./data
    ''
  );
in
{
  options.optionals.features.ST.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "ST, AI RPG Service";
  };
  config = lib.mkIf config.optionals.features.ST.enable {
    services.sillytavern = {
      enable = true;
      port = 6720;
      configFile = configSrc;
    };
    systemd.services.sillytavern.serviceConfig.ExecStartPre =
      "${pkgs.bash}/bin/bash -c 'cp --remove-destination ${configSrc} /var/lib/SillyTavern/config.yaml && chmod 600 /var/lib/SillyTavern/config.yaml'";
    security.acme.certs."moontier.online".extraDomainNames = [ "st.moontier.online" ];
    services.nginx.virtualHosts."st.moontier.online" = {
      useACMEHost = "moontier.online";
      forceSSL = true;
      extraConfig = ''
        allow 192.168.1.0/24;
        allow 100.64.0.0/10;
        allow 127.0.0.1;
        deny all;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:6720";
        proxyWebsockets = true;
      };
    };
  };
}

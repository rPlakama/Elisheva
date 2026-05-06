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
        ipv4: 0.0.0.0
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
    optionals.features.nginx.proxyServices.st = 6720;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.st;
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
  options.features.st.enable = lib.mkEnableOption "SillyTavern AI RPG";

  config = lib.mkIf cfg.enable {
    features.preservation.persistDirs.system = [ "/var/lib/SillyTavern" ];

    services.sillytavern = {
      enable = true;
      port = 6720;
      configFile = configSrc;
    };

    systemd.services.sillytavern.serviceConfig.ExecStartPre =
      "${pkgs.bash}/bin/bash -c 'cp --remove-destination ${configSrc} /var/lib/SillyTavern/config.yaml && chmod 600 /var/lib/SillyTavern/config.yaml'";
    features.unifiedDNS.proxyServices.st = 6720;
  };
}
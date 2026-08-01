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
  # The nixos sillytavern module symlinks /var/lib/SillyTavern/config.yaml to
  # configFile. Point it at a writable, persisted path and materialise it once
  # via tmpfiles, so the app can write back to its config instead of a read-only
  # store path (no more ExecStartPre cp hack).
  dataConfig = "/var/lib/SillyTavern/config-store.yaml";
in
{
  options.features.st.enable = lib.mkEnableOption "SillyTavern AI RPG";

  config = lib.mkIf cfg.enable {
    features.preservation.system.directories = [ "/var/lib/SillyTavern" ];

    services.sillytavern = {
      enable = true;
      port = 6720;
      configFile = dataConfig;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/SillyTavern 0700 sillytavern sillytavern - -"
      "f ${dataConfig} 0600 sillytavern sillytavern - ${configSrc}"
    ];

    features.unifiedDNS.proxyServices.st = 6720;
  };
}

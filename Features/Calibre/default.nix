{
  lib,
  config,
  ...
}:
let
  cfg = config.features.calibre;
  tcpPort = 9090;
in
{
  options.features.calibre.enable = lib.mkEnableOption "Kavita reading server";
  config = lib.mkIf cfg.enable {
    features = {
      mediaPermissions.enable = true;
      preservation.persistDirs.system = [ "/var/lib/calibre-web" ];
      unifiedDNS.proxyServices.calibre = tcpPort;
    };
    networking.firewall.allowedTCPPorts = [ tcpPort ];
    systemd.services.calibre.serviceConfig.SupplementaryGroups = [ "media" ];
    services.calibre-web = {
      enable = true;
      listen = {
        port = tcpPort;
        ip = "0.0.0.0";
      };
      user = "calibre-web";
      options = {
        enableBookUploading = true;
      };
      group = "media";

    };
  };
}

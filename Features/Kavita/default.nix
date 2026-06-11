{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.features.kavita;
in
{

  options.features.kavita.enable = lib.mkEnableOption "Kavita reading server";
  config = lib.mkIf cfg.enable {
    sops.secrets."kavita/token" = {
      owner = "kavita";
    };
    features = {
      mediaPermissions.enable = true;
      preservation.persistDirs.system = [ "/var/lib/kavita" ];
      unifiedDNS.proxyServices.kavita = 3034;
    };
    networking.firewall.allowedTCPPorts = [ 3034 ];
    systemd.services.kavita.serviceConfig.SupplementaryGroups = [ "media" ];
    services.kavita = {
      package = inputs.kavita-pkg.packages.${pkgs.stdenv.hostPlatform.system}.kavita;
      enable = true;
      tokenKeyFile = config.sops.secrets."kavita/token".path;
      settings.Port = 3034;
    };
  };
}

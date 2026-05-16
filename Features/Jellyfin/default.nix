{

  config,
  lib,
  ...
}:
let
  cfg = config.optionals.features.jellyfin;
in
{
  options.optionals.features.jellyfin.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Jellyfin is an... media server thingy";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    core.features.mediaPermissions.enable = true;
    optionals.features.unifiedDNS.proxyServices.jellyfin = 8096;
    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = false; # Explicity  just in case;
    };
    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];
    networking.firewall.allowedUDPPorts = [
      1900 # DLNA
      7359 # Auto-discovery
    ];
  };
}

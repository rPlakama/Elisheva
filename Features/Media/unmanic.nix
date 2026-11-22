{
  config,
  lib,
  ...
}:
let
  featureCall = config.features;
  localHost = "127.0.0.1";
  serverPort = 8226;
  containerPort = 8888;
  dataDir = "/var/lib/unmanic";
  unmanicUid = 2001;
  mediaGid = featureCall.mediaPermissions.gid;
in
{
  options.features.unmanic.enable = lib.mkEnableOption "Unmanic transcoding service (OCI container)";

  config = lib.mkIf featureCall.unmanic.enable {
    features = {
      mediaPermissions = {
        enable = true;
        writableServices = [ "podman-unmanic" ];
      };
      preservation.system.directories = [ dataDir ];
      unifiedDNS.proxyServices.unmanic = {
        port = serverPort;
        icon = "sh-unmanic";
        description = "Library optimiser for media transcoding";
      };
      virtualization.containers.unmanic = {
        image = "josh5/unmanic:latest";
        user = "${toString unmanicUid}:${toString mediaGid}";
        ports = [ "${localHost}:${toString serverPort}:${toString containerPort}" ];
        volumes = [
          "${dataDir}/config:/config"
          "/media:/library"
          "${dataDir}/cache:/tmp/unmanic"
        ];
        environment = {
          PUID = toString unmanicUid;
          PGID = toString mediaGid;
          TZ = config.time.timeZone;
        };
        devices = [ "/dev/dri:/dev/dri" ];
        extraOptions = [
          "--group-add"
          (toString config.ids.gids.video)
          "--group-add"
          (toString config.ids.gids.render)
        ];
      };
    };

    users.users = {
      unmanic = {
        isSystemUser = true;
        group = "media";
        uid = unmanicUid;
        extraGroups = [
          "video"
          "render"
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0750 unmanic media -"
      "d ${dataDir}/config 0750 unmanic media -"
      "d ${dataDir}/cache 0750 unmanic media -"
    ];
  };
}

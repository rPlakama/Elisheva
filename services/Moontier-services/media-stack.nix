{ lib, ... }:

let
  mediaServicesWithPermissions = [
    "jackett"
    "jellyfin"
    "bazarr"
    "sonarr"
    "radarr"
    "readarr"
  ];
  mediaNonPermissions = [
    "prowlarr"
    "flaresolverr"
  ];
in

{
  services = (
    lib.genAttrs mediaServicesWithPermissions (name: {
      enable = true;
      openFirewall = true;
      group = "media";
    })
    // lib.genAttrs mediaNonPermissions (name: {
      enable = true;
      openFirewall = true;
    })
  );
}

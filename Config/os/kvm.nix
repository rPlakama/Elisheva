{ lib, isDesktop, ... }:

{
  virtualisation.libvirtd.enable = isDesktop;
  users.users.yourusername.extraGroups = lib.optionals isDesktop [ "libvirtd" ];
}

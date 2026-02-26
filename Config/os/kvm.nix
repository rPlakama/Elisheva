{ lib, isDesktop, ... }:

{
  virtualisation.libvirtd.enable = isDesktop;
  users.users.rplakama.extraGroups = lib.optionals isDesktop [ "libvirtd" ];
}

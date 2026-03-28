{
  lib,
  isDesktop,
  isCenturia,
  ...
}:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./locale.nix
    ./hardware.nix
    ./networking.nix
    ./users.nix
    ./nix-configuration.nix
  ]
  ++ lib.optionals isCenturia [
    ./Centuria-harware.nix
  ]
  ++ lib.optionals isDesktop [
    ./desktop-boot.nix
    ./desktop-hardware.nix
  ];
}

{ isDesktop, lib, ... }:
{
  imports = [
    ./hardware.nix
    ./boot.nix
    ./environment.nix
  ]
  ++ lib.optionals isDesktop [
    ./isDesktop_boot.nix
  ];
}

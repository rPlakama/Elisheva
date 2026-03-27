{ isDesktop, lib, ... }:
{
  imports = [
    ./networking.nix
    ./servicesCli.nix
    ./servicesGraphical.nix
  ]
  ++ lib.optionals isDesktop [
    ./isDesktop_services.nix
  ];
}

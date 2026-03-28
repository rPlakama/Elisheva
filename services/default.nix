{
  lib,
  isMoontier,
  isDesktop,
  isCenturia,
  ...
}:
{
  imports = [
    ./shared-services.nix
  ]
  ++ lib.optionals isCenturia [
    ./Centuria-services.nix
  ]
  ++ lib.optionals isMoontier [
    ./Moontier-services
  ];
}

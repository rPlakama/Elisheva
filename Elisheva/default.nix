{
  imports = [
    ./services/default.nix
    ./hardware/default.nix
    ./hardware-configuration.nix
    ./packages/specific.nix
    ./programs/default.nix
    ./portals.nix
    ./boot/default.nix
  ];
}

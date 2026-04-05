{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./locale.nix
    ./networking.nix
    ./users.nix
    ./nix-configuration.nix
  ];
}

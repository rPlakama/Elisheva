{ lib, ... }:
{
  # Using TuneD instead.
  services.power-profiles-daemon.enable = lib.mkForce false;
}

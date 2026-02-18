{ isDesktop, lib, ... }:
{
  imports = [
    ./networking.nix
    ./udisks2.nix
    ./devmon.nix
    ./pipewire.nix
    ./resolved.nix
    ./scx.nix
    ./upower.nix
    ./tuned.nix
    ./bpftune.nix
    ./power-profiles-daemon.nix
    ./podman.nix
    ./flatpak.nix
  ] ++ lib.optional isDesktop ./dank-material-shell.nix;
}

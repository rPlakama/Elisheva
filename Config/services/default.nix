{ ... }:
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
    ./dank-material-shell.nix
    ./podman.nix
    ./flatpak.nix
  ];
}

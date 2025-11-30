{...}: {
  system.nixos-init.enable = true;
  boot.initrd.systemd.enable = true;
  system.etc.overlay.enable = true;
  services.userborn.enable = true;
}

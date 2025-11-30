{ ... }: {

  boot = {
    loader.systemd-boot.enable = true;
    initrd.systemd.enable = true;
    };
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}

{ ... }:
{
  boot = {
    initrd = {
      systemd.network.wait-online.enable = false;
      systemd.enable = true;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 0;
    };
  };
}

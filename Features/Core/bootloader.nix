{
  config,
  lib,
  ...
}:
let
  headless = config.core.headless;
in
{

  systemd.services.NetworkManager-wait-online.enable = false;
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 0;
    };
    plymouth = {
      enable = !headless;
      theme = "bgrt";
    };
    kernelParams = lib.mkIf (!headless) [
      "quiet"
      "splash"
      "udev.log_level=3"
    ];
    initrd.systemd.enable = true;
  };
}

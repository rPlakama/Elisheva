{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  headless = config.core.headless;
in
{
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
    kernelParams = mkIf (!headless) [
      "quiet"
      "splash"
      "udev.log_level=3"
    ];
    initrd.systemd.enable = true;
  };
}

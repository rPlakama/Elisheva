{
  config,
  lib,
  ...
}:
lib.mkMerge [
  (lib.mkIf (config.networking.hostName == "Centuria") {
    services = {
      xserver.videoDrivers = [ "nvidia" ];
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1022", ATTR{device}=="0x1483", ATTR{power/wakeup}="disabled"
      '';
    };
    hardware.nvidia = {
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  })

  (lib.mkIf (config.networking.hostName == "Elisheva") {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings.General.Experimental = true;
    };
  })

  {
    hardware.enableAllFirmware = true;
    hardware.graphics.enable = true;
  }
]

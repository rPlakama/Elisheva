{
  lib,
  config,
  pkgs,
  isDesktop,
  ...
}:
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

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "amd_pstate=active"
    ]
    ++ lib.optionals (config.networking.hostName == "Elisheva") [
      "video=eDP-1:1920x1080@72"
    ]
    ++ lib.optionals isDesktop [
      "kvm-amd"
    ];
    plymouth = {
      enable = isDesktop;
      theme = "bgrt";
    };
  };
}

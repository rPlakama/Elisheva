{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.core;
  isLaptop = config.core.isLaptop;
in {
  config = lib.mkIf cfg.enable {
    services = {
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
      upower.enable = isLaptop;
      power-profiles-daemon.enable = isLaptop;
      bpftune.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      resolved.enable = true;
      gvfs.enable = true;
      fwupd.enable = true;
      pipewire = {
        enable = !config.core.headless;
        alsa.enable = !config.core.headless;
        alsa.support32Bit = !config.core.headless;
        pulse.enable = !config.core.headless;
      };
      tailscale = {
        enable = true;
        openFirewall = true;
      };
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
    };

    features.preservation.system.directories = [
      "/var/lib/fwupd"
    ];
  };
}

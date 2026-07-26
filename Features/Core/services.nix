{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.features.core;
  isLaptop = config.core.isLaptop;
  headless = config.core.headless;
in
{
  config = mkIf cfg.enable {
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
        enable = !headless;
        alsa.enable = !headless;
        alsa.support32Bit = !headless;
        pulse.enable = !headless;
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

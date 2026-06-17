{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.core;
  isLaptop = config.core.isLaptop;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
      upower.enable = isLaptop;
      bpftune.enable = true;
      devmon.enable = true;
      udisks2.enable = true;
      resolved.enable = true;
      gvfs.enable = true;
      fwupd.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
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

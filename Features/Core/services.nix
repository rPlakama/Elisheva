{
  config,
  lib,
  inputs,
  ...
}:
let
  headless = config.core.headless;
  usesPPD = config.core.isLaptop.usesPPD;
  isLaptop = config.core.isLaptop.enable;
  keyLayout = config.core.keyboardLayout;
in
{

  services = {
    upower.enable = lib.mkDefault isLaptop;
    power-profiles-daemon.enable = usesPPD;
    # bpftune.enable = true;
    devmon.enable = !headless;
    udisks2.enable = !headless;
    resolved.enable = true;
    gvfs.enable = !headless;
    fwupd.enable = !headless;

    xserver.xkb.layout = lib.mkIf (!headless) keyLayout;

    kmscon = {
      enable = !headless;
      config.hwaccel = true;
      useXkbConfig = true;
    };

    pipewire = {
      enable = !headless;
      alsa = {
        enable = !headless;
        support32Bit = !headless;
      };
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

  features.preservation.system.directories = lib.mkIf (!headless) [
    "/var/lib/fwupd"
  ];
}

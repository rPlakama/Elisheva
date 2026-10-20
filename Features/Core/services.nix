{
  config,
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
    upower.enable = isLaptop;
    scx.enable = false;
    power-profiles-daemon.enable = usesPPD;
    # bpftune.enable = true;
    devmon.enable = !headless;
    udisks2.enable = true;
    resolved.enable = true;
    gvfs.enable = !headless;
    fwupd.enable = true;

    xserver.xkb.layout = keyLayout;

    kmscon = {
      enable = true;
      hwRender = true;
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

  features.preservation.system.directories = [
    "/var/lib/fwupd"
  ];
}

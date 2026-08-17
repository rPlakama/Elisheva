{
  config,
  pkgs,
  ...
}:
let
  headless = config.core.headless;
  usesAuto-cpufreq = config.core.isLaptop.usesAuto-cpufreq;
  usesPPD = config.core.isLaptop.usesPPD;
  isLaptop = config.core.isLaptop.enable;
in
{
  programs.auto-cpufreq = {
    enable = usesAuto-cpufreq;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };

      battery = {
        governor = "powersave";
        turbo = "auto";
      };
    };
  };
  services = {
    upower.enable = isLaptop;
    scx.enable = true;
    power-profiles-daemon.enable = usesPPD;
    bpftune.enable = true;
    devmon.enable = true;
    udisks2.enable = true;
    resolved.enable = true;
    gvfs.enable = true;
    fwupd.enable = true;
    pipewire = {
      enable = !headless;
      alsa = {
        enable = !headless;
        support32Bit = !headless;
      };
      pulse.enable = !headless;
      wireplumber.extraConfig = {
        "51-follow-newest" = {
          "wireplumber.settings" = {
            "device.restore-profile" = true;
            "default.node.restore" = false;
            "default.policy.follow" = true;
            "default.policy.move" = true;
          };
        };
      };
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

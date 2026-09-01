{
  config,
  inputs,
  ...
}:
let
  headless = config.core.headless;
  usesAuto-cpufreq = config.core.isLaptop.usesAuto-cpufreq;
  usesPPD = config.core.isLaptop.usesPPD;
  isLaptop = config.core.isLaptop.enable;
in
{
  imports = [ inputs.auto-cpufreq.nixosModules.default ];

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
    devmon.enable = !headless;
    udisks2.enable = !headless;
    resolved.enable = true;
    gvfs.enable = !headless;
    fwupd.enable = true;
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

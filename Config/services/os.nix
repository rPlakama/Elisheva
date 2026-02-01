{ lib, config, ... }:

{

  # System services (Storage, DNS, Scheduling...)
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  services = lib.mkMerge [
    {
      gvfs.enable = true;
      udisks2.enable = true;
      pipewire.alsa.enable = true;
      resolved.enable = true;
      scx.enable = true;
      upower.enable = true;
    }

    (lib.mkIf (config.networking.hostName == "Moontier") {
      tuned.enable = true;
      bpftune.enable = true;
      scx.scheduler = "scx_lavd";
    })

    (lib.mkIf (config.networking.hostName == "Elisheva") {
      scx.scheduler = "scx_lavd";
      tuned = {
        enable = true;
        settings.dynamic_tuning = true;
      };
    })

    (lib.mkIf (config.networking.hostName == "Centuria") {
      scx.scheduler = "scx_rusty";
      bpftune.enable = true;
    })
  ];
}

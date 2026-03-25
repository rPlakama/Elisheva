{
  isDesktop,
  isElisheva,
  isCenturia,
  ...
}:
{
  services = {
    upower.enable = true;
    bpftune.enable = true;

    scx = {
      enable = true;
      scheduler = if isElisheva then "scx_lavd" else "scx_rusty";
      extraArgs = if isElisheva then [ "--powersave" ] else [ ];
    };

    devmon.enable = true;
    udisks2.enable = true;
    pipewire.alsa.enable = true;
    flatpak.enable = isDesktop;
  };

  hardware.nvidia-container-toolkit.enable = isCenturia;
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}

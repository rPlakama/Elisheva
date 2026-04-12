{
  isCenturia,
  ...
}:
{

  services = {
    flatpak.enable = true;
    pipewire.alsa.enable = true;

  };
  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = true;
      enableNvidia = isCenturia;
      enableOnBoot = true;
      autoPrune.enable = true;
    };
  };

}

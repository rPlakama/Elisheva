{config, ...}: {
  programs.steam.enable = config.networking.hostName == "Centuria";
}

{
  config,
  ...
}:
{
  services.flatpak.enable = config.networking.hostName == "Centuria" || config.networking.hostName == "Elisheva";
}

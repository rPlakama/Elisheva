{
  config,
  ...
}:
{
  services.flatpak.enable = config.networking.hostName == "Centuria";
}

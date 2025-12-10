{ ... }:
{
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  services.resolved.enable = true;
}

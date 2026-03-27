{
  isCenturia,
  lib,
  ...
}:
{

  # -- What I can say.
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.hardware.openrgb = {
    enable = isCenturia;
    motherboard = "amd";
  };

  services.sunshine = {
    enable = isCenturia;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

}

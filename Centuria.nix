{...}: {
  imports = [
    ./Base.nix
    ./Centuria
  ];
  system.stateVersion = "25.05";
  networking = {
    hostName = "Centuria";
    networkmanager.enable = true;
  };

  services.flatpak = {
    enable = true;
    packages = [
      {
        appId = "com.lunarclient.LunarClient";
        origin = "flathub";
      }
    ];
  };
}

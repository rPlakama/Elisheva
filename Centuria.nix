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

}

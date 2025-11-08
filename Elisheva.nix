{...}: {
  imports = [
    ./Base.nix
    ./Elisheva
  ];
  system.stateVersion = "25.05";
  networking = {
    hostName = "Elisheva";
    networkmanager.enable = true;
  };
}

{ pkgs, config, ... }:
{
  programs.steam = {
    enable = config.networking.hostName == "Centuria" || config.networking.hostName == "Elisheva";
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}

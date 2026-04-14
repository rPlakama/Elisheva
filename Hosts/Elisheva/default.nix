{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../Features
  ];

  networking.hostName = "Elisheva";
  environment.systemPackages = with pkgs; [
    moonlight-qt # << Victim of evil sunshine
  ];

  core.user = "rplakama";
  optionals.features = {
    niri.enable = true;
    neovim.enable = true;
  };
}

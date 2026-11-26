{ config, ... }:
let
  user = config.core.user;
  headless = config.core.headless;
in
{
  security = {
    sudo-rs.enable = true;
    rtkit.enable = !headless;
  };

  networking.networkmanager.enable = true;

  users.users.${user} = {
    group = user;
    extraGroups = [ "networkmanager" ];
  };

  programs = {
    fish = {
      enable = true;
      generateCompletions = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
  documentation = {
    dev.enable = !headless;
    man.enable = true;
  };
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };
}

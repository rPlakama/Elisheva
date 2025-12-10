{ pkgs, ... }:
{
  users.users.rplakama = {
    isNormalUser = true;
    description = "rPlakama.";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
}

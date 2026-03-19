{ pkgs, ... }:
{
  users.users.rplakama = {
    isNormalUser = true;
    description = "rPlakama.";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.fish;
  };
}

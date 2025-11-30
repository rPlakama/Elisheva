{pkgs, ...}: {
  users.mutableUsers = false;
  systemd.sysusers.enable = true;
  users.users.rplakama = {
    isNormalUser = true;
    description = "I like Shark Girls.";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
}

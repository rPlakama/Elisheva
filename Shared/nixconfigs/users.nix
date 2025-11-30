{pkgs, ...}: {
  users.users.rplakama = {
    isNormalUser = true;
    description = "Hi.";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
}

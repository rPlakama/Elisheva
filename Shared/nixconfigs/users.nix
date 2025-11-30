{pkgs, ...}: {
  users.mutableUsers = false;
  users.users.rplakama = {
    isNormalUser = true;
    description = "I like Shark Girls.";
    hashedPasswordFile = "./rplakama.txt";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
}

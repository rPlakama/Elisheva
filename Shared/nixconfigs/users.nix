{pkgs, ...}: {
  users.mutableUsers = false;
  services.userborn.enable = true;
  users.users.rplakama = {
    isNormalUser = true;
    description = "Hi.";
    hashedPassword = "$y$j9T$/IUBMaO9Dx6HKTarmsvjq1$y8CWBVWIxMYCkMYLOKrhSSnW2/ESE1JeC8BIXAMwtj1";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };
}

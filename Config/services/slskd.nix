{...}: {
  networking.hosts = {
    "127.0.0.1" = ["slskd.nix.com"];
    "::1" = ["slskd.nix.com"];
  };

  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = "slskd.nix.com";
    user = "rplakama";
    group = "users";
    environmentFile = "/home/rplakama/Dropbox/env.yaml";
    settings.shares.directories = ["/home/rplakama/Music"];
  };
}

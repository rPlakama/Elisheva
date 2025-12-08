{lib, ...}: {
  systemd.services.slskd.serviceConfig.ProtectHome = lib.mkForce "false";
  services.slskd = {
    enable = true;
    domain = "slskd.nix.com";
    openFirewall = true;
    user = "rplakama";
    group = "users";
    environmentFile = "/home/rplakama/Dropbox/env.yaml";
    settings = {
      shares = {
        directories = ["/home/rplakama/Music/"];
        filters = ["music\.sh$"];
      };
    };
  };
}

{ ... }:
{
  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = "slskd.nix.com";

    environmentFile = "/home/rplakama/Dropbox/env.yaml";

    settings = {
      directories = {
        downloads = "/mnt/secondary/music/downloads";
        incomplete = "/mnt/secondary/music/incomplete";
      };

      shares = {
        directories = [ "/home/rplakama/Music/" ];
      };

      flags = {
        force_share_scan = true;
      };

      soulseek = {
        listen_port = 50300;
      };
    };
  };

  systemd.services.slskd.serviceConfig.ReadWritePaths = [ "/mnt/secondary" ];
}

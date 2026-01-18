{ ... }:
{
  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = "slskd.nix.com";

    environmentFile = "/home/rplakama/Dropbox/env.yaml";

    settings = {
      directories = {
        downloads = "/mnt/@media/music/downloads";
        incomplete = "/mnt/@media/music/incomplete";
      };

      shares = {
        directories = [ "/mnt/@media/music/downloads" ];
      };

      flags = {
        force_share_scan = true;
      };

      soulseek = {
        listen_port = 50300;
      };
    };
  };

  systemd.services.slskd.serviceConfig.ReadWritePaths = [ "/mnt/@media" ];
}

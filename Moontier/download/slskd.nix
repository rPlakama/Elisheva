{ ... }:
{
  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = "slskd.nix.com";
    environmentFile = "/home/rplakama/Dropbox/env.yaml";
    settings = {
      shares.directories = [ "/mnt/@media/music/downloads" ];
      slskd.settings.directories.downloads = "/home/rplakama/Music/";
      flags.force_share_scan = true;
      soulseek.listen_port = 50300;
      web.authentication.api_keys = {
        "homepage" = {
          key = "6434bc876f03b35431d91284403c7988aa6c0c8cccb2801456a4b70997063203";
          role = "readonly";
          cidr = [ "0.0.0.0/0" ];
        };
      };
    };
  };
}

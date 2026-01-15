{ ... }:
{
  services.slskd = {
    enable = true;
    openFirewall = true;
    domain = "slskd.nix.com";
    environmentFile = "/home/rplakama/Dropbox/env.yaml";
    settings = {
      shares.directories = [ "/home/rplakama/Music/" ];
      slskd.settings.directories.downloads = "/home/rplakama/Music/";
      flags.force_share_scan = true;
      soulseek.listen_port = 50300;
    };
  };
}

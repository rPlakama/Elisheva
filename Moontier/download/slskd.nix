{ lib, ... }:

let
  readKey = path: lib.removeSuffix "\n" (builtins.readFile path);
in
{
  services.slskd = {
    enable = true;
    openFirewall = true;
    group = "users";
    domain = "slskd.nix.com";
    environmentFile = "/home/rplakama/Keys/slskd.yaml";

    settings = {
      shares.directories = [ "/home/rplakama/Music/" ];
      directories.downloads = "/mnt/@media/music/library";
      directories.incomplete = "/mnt/@media/music/downloads";
      flags.force_share_scan = true;
      soulseek.listen_port = 50300;

      web.authentication.api_keys = {
        "homepage" = {
          key = readKey /home/rplakama/Keys/slskd-key.txt;
          role = "readonly";
          cidr = [ "0.0.0.0/0" ];
        };
      };
    };
  };
}

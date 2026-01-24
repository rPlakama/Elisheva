{ config, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../network/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "dashboard/slskd_apikey" = {
        owner = "slskd";
      };
      "slskd/username" = {
        owner = "slskd";
      };
      "slskd/password" = {
        owner = "slskd";
      };
    };
    templates."slskd.env" = {
      content = ''
                SLSKD_WEB__AUTHENTICATION__API_KEYS__homepage__KEY=${
                  config.sops.placeholder."dashboard/slskd_apikey"
                }
                SLSKD_WEB__AUTHENTICATION__API_KEYS__homepage__ROLE=readonly
                SLSKD_WEB__AUTHENTICATION__API_KEYS__homepage__CIDR=0.0.0.0/0
        	SLSKD_SLSK_USERNAME=${config.sops.placeholder."slskd/username"}
        	SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/password"}
      '';
      owner = "slskd";
      group = "users";
    };
  };

  services.slskd = {
    enable = true;
    openFirewall = true;
    group = "users";
    domain = "slskd.nix.com";

    environmentFile = config.sops.templates."slskd.env".path;

    settings = {
      shares.directories = [ "/home/rplakama/Music/" ];
      directories.downloads = "/mnt/@media/music/library";
      directories.incomplete = "/mnt/@media/music/downloads";
      flags.force_share_scan = true;
      soulseek.listen_port = 50300;
    };
  };
}

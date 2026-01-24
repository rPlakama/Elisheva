{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "cloudflared/cert.pem" = {
        path = "/home/rplakama/.cloudflared/cert.pem";
        owner = "rplakama";
      };
      "cloudflared/tunnel_credentials" = {
        owner = "rplakama";
      };
    };
  };

  services.cloudflared = {
    enable = true;
    certificateFile = config.sops.secrets."cloudflared/cert.pem".path;
    tunnels = {
      "7b24107e-944f-4aac-9560-19bb970cd3ce" = {
        credentialsFile = config.sops.secrets."cloudflared/tunnel_credentials".path;
        default = "http_status:404";
        ingress = {
          "dashboard.082374903.xyz" = {
            service = "http://localhost:8082";
          };
          "jellyfin.082374903.xyz" = {
            service = "http://localhost:8096";
          };
          "sonarr.082374903.xyz" = {
            service = "http://localhost:8989";
          };
          "radarr.082374903.xyz" = {
            service = "http://localhost:7878";
          };
          "prowlarr.082374903.xyz" = {
            service = "http://localhost:9696";
          };
          "lidarr.082374903.xyz" = {
            service = "http://localhost:8686";
          };
          "jellyseerr.082374903.xyz" = {
            service = "http://localhost:5055";
          };
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.cloudflared ];
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.bots;
  user = config.core.user;
in
{
  options.features.bots = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Bots Configuration";
    };
    whatsapp-bot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WhatsApp Bot";
      };
    };
    discord-bot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Discord Bot";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    features.preservation.home.directories = [ "ascending-bots" ];

    systemd.services = lib.mkMerge [
      (lib.mkIf cfg.whatsapp-bot.enable {
        whatsapp-bot = {
          description = "WhatsApp Bot";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          path = with pkgs; [
            ffmpeg
            imagemagick
            libwebp
          ];

          serviceConfig = {
            ExecStart = "/home/${user}/ascending-bots/whatsapp-bot/whatsapp-summarizer-linux-amd64";
            WorkingDirectory = "/home/${user}/ascending-bots/whatsapp-bot";
            User = user;
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })

      (lib.mkIf cfg.discord-bot.enable {
        discord-bot = {
          description = "Discord Bot";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = {
            ExecStart = "/home/${user}/ascending-bots/discord-bot/discord-bot-linux-amd64";
            WorkingDirectory = "/home/${user}/ascending-bots/discord-bot";
            User = user;
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      })
    ];
  };
}

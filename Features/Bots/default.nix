{
  config,
  lib,
  ...
}:

let
  cfg = config.features.whatsBot;
in

{
  options.features.whatsBot.enable = lib.mkEnableOption "WhatsApp Bot";
  config = lib.mkIf cfg.enable {

    systemd.services = {
      whatsapp-summarizer = {
        description = "WhatsApp Bot";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = "/home/${config.core.user}/bot-ascending/whatsapp-summarizer-linux-amd64";
          WorkingDirectory = "/home/${config.core.user}/bot-ascending";
          User = config.core.user;
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
  };
}
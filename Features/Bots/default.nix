{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.whatsBot;
in

{
  options.optionals.features.whatsBot.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Zapzap Configuration";
    default = false;
  };
  config = lib.mkIf cfg.enable {

    systemd.services = {
      whatsapp-summarizer = {
        description = "WhatsApp Bot";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = "/home/rplakama/bot-ascending/whatsapp-summarizer-linux-amd64";
          WorkingDirectory = "/home/rplakama/bot-ascending";
          User = "rplakama";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
  };
}
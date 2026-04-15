{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.whats_bot;
in

{
  options.optionals.features.whats_bot.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Zapzap Configuration";
    default = true;
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

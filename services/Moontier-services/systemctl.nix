{ ... }:
{
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
}

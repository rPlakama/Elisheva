{ pkgs, ... }:
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

    # < -- Time to "Bater o ponto"
    moontier-sleep-wake = {
      description = "Sleep and wake";

      script = ''
        WAKE_TIME=$(${pkgs.coreutils}/bin/date -d '07:30' +%s)
        ${pkgs.util-linux}/bin/rtcwake -m off -t $WAKE_TIME
      '';

      serviceConfig = {
        Type = "oneshot";
      };
    };
    systemd.timers.moontier-sleep-wake = {
      description = "Sleep cycle timer";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "*-*-* 01:00:00";
        Persistent = true;
      };
    };
  };
}

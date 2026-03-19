{ pkgs, ... }:

{
  systemd.services.auto-suspend = {
    description = "Suspender o sistema às 02:00 da manhã";
    script = "${pkgs.systemd}/bin/systemctl suspend";
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.auto-suspend = {
    description = "Timer para ativar o auto-suspend às 02:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
    };
  };

  systemd.services.auto-wake = {
    description = "Serviço vazio apenas para engatilhar o despertar do sistema";
    script = "${pkgs.coreutils}/bin/true";
    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.timers.auto-wake = {
    description = "Timer para acordar o sistema às 08:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 08:00:00";
      WakeSystem = true;
      Persistent = true;
    };
  };
}

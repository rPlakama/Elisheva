{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.optionals.features.gpuScreenRecorder.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "GPU Screen Recorder Replay Buffer";
  };

  config = lib.mkIf config.optionals.features.gpuScreenRecorder.enable {
    programs.gpu-screen-recorder.enable = true;

    environment.systemPackages = with pkgs; [
      libnotify
      pulseaudio
    ];

    systemd.user.services.gpu-screen-recorder-replay = {
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Clips";
        ExecStart = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder -w portal -c mp4 -f 60 -r 60 -o %h/Clips/";
        Restart = "always";
        RestartSec = 3;
      };
    };
  };
}

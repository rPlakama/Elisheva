{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optionals.features.galleryDl;
  user = config.core.user;
  downloadPath = "/media/mangas/download";

  galleryDlConfig = {
    extractor = {
      base-directory = downloadPath;
      archive = "${downloadPath}/.archive.sqlite3";
      mangafire = {
        lang = "pt-br";
        postprocessors = [
          {
            name = "zip";
            extension = "cbz";
          }
        ];
      };
    };
    downloader = {
      retries = 3;
      timeout = 8.0;
    };
  };
in
{
  options.optionals.features.galleryDl = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "gallery-dl manga downloader with daily systemd timer";
    };
    urls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "" ];
      description = "List of manga URLs to download daily";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gallery-dl ];

    hjem.users.${user}.files.".config/gallery-dl/config.json".text = builtins.toJSON galleryDlConfig;

    systemd.services.gallery-dl = {
      description = "gallery-dl manga downloader";
      serviceConfig = {
        Type = "oneshot";
        User = user;
        ExecStart = pkgs.writeShellScript "gallery-dl-run" ''
          ${pkgs.gallery-dl}/bin/gallery-dl \
            --config /home/${user}/.config/gallery-dl/config.json \
            ${lib.concatMapStringsSep " \\\n            " (url: "\"${url}\"") cfg.urls}
        '';
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.timers.gallery-dl = {
      description = "Daily manga download at 8PM";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 20:00:00";
        Persistent = true;
      };
    };
  };
}

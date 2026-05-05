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
      rate = "1.5M";

      sleep = "2.0-4.5";
      sleep-request = "0.5-2.0";
      sleep-extractor = "1.0-3.0";
      sleep-chapter = "05.0-10.0";
      sleep-gallery = "15.0-35.0";

      postprocessors = [
        {
          name = "zip";
          extension = "cbz";
          mode = "after";
        }
      ];
      mangafire = {
        lang = "pt-br";
        flaresolverr = "http://127.0.0.1:8191/v1";
      };
    };
    downloader = {
      retries = 5;
      timeout = 10.0;
      rate = "1.5M";
      retry-codes = [
        429
        503
        403
        520
      ];
    };
  };
in
{
  options.optionals.features.galleryDl = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "gallery-dl manga downloader (Direct connection with stealth/slow intervals)";
    };
    urls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "" ];
      description = "List of manga URLs to download daily";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gallery-dl
    ];

    hjem.users.${user}.files.".config/gallery-dl/config.json".text = builtins.toJSON galleryDlConfig;

    systemd.services.gallery-dl = {
      description = "gallery-dl Manga Downloader (Stealth Mode)";
      after = [
        "network.target"
        "flaresolverr.service"
      ];
      wants = [ "flaresolverr.service" ];
      path = with pkgs; [
        p7zip
        zip
      ];
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
      description = "Once a day";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "00:00";
        Persistent = true;
      };
    };
  };
}

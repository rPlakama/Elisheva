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

      user-agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36";
      headers = {
        Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7";
        Accept-Language = "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7";
        Accept-Encoding = "gzip, deflate, br";
        "sec-ch-ua" = "\"Chromium\";v=\"124\", \"Google Chrome\";v=\"124\", \"Not-A.Brand\";v=\"99\"";
        "sec-ch-ua-mobile" = "?0";
        "sec-ch-ua-platform" = "\"Windows\"";
        "sec-fetch-dest" = "document";
        "sec-fetch-mode" = "navigate";
        "sec-fetch-site" = "none";
        "sec-fetch-user" = "?1";
        "upgrade-insecure-requests" = "1";
        "priority" = "u=0, i";
        DNT = "1";
      };
      postprocessors = [
        {
          name = "zip";
          extension = "cbz"; # Better accepted by Kavita
          mode = "after";
        }
      ];
      mangafire = {
        lang = "pt-br";
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

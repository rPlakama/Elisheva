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
      ao3 = {
        format = "epub";
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
      description = "gallery-dl manga/literature downloader (stealth/slow intervals)";
    };
    mangas.secretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the SOPS-decrypted file containing manga URLs (one per line)";
    };
    literature.secretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the SOPS-decrypted file containing literature/fanfic URLs (one per line)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gallery-dl
    ];

    sops.secrets."gallery-dl/ao3-username" = { };
    sops.secrets."gallery-dl/ao3-password" = { };

    sops.templates."gallery-dl-secrets.json" = {
      owner = user;
      content = builtins.toJSON {
        extractor.ao3 = {
          username = config.sops.placeholder."gallery-dl/ao3-username";
          password = config.sops.placeholder."gallery-dl/ao3-password";
        };
      };
    };

    hjem.users.${user}.files.".config/gallery-dl/config.json".text = builtins.toJSON galleryDlConfig;

    # --- Mangas
    systemd.services.gallery-dl-mangas = {
      description = "gallery-dl Manga Downloader";
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
        ExecStart = pkgs.writeShellScript "gallery-dl-mangas-run" ''
          ${pkgs.gallery-dl}/bin/gallery-dl \
            --config /home/${user}/.config/gallery-dl/config.json \
            --input-file "${cfg.mangas.secretFile}"
        '';
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.timers.gallery-dl-mangas = {
      description = "gallery-dl mangas — once a day";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "00:00";
        Persistent = true;
      };
    };

    # --- Literature
    systemd.services.gallery-dl-literature = {
      description = "gallery-dl Literature/Fanfic Downloader";
      after = [ "network.target" ];
      path = with pkgs; [
        p7zip
        zip
      ];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        ExecStart = pkgs.writeShellScript "gallery-dl-literature-run" ''
          ${pkgs.gallery-dl}/bin/gallery-dl \
            --config /home/${user}/.config/gallery-dl/config.json \
            --config ${config.sops.templates."gallery-dl-secrets.json".path} \
            --input-file "${cfg.literature.secretFile}"
        '';
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.timers.gallery-dl-literature = {
      description = "gallery-dl literature — once a day";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
      };
    };
  };
}

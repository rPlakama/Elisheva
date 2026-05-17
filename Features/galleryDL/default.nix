{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.optionals.features.galleryDl;
  user = config.core.user;

  baseConfig = {
    extractor = {
      rate = "1.5M";
      sleep = "2.0-4.5";
      sleep-request = "0.5-2.0";
      sleep-extractor = "1.0-3.0";
      sleep-chapter = "05.0-10.0";
      sleep-gallery = "15.0-35.0";
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

  mkGalleryDlConfig =
    path: postprocessors:
    baseConfig
    // {
      extractor = baseConfig.extractor // {
        base-directory = path;
        archive = "${path}.archive.sqlite3";
        postprocessors = postprocessors;
      };
    };

  # Mangas get zipped into cbz archives
  mangasConfig = mkGalleryDlConfig cfg.mangas.downloadPath [
    {
      name = "zip";
      extension = "cbz";
      mode = "after";
    }
  ];

in
{
  options.optionals.features.galleryDl = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "gallery-dl (manga) & FanFicFare (literature) downloader";
    };
    mangas.secretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the SOPS-decrypted file containing manga URLs (one per line)";
    };
    mangas.downloadPath = lib.mkOption {
      type = lib.types.str;
      description = "Directory to download manga into";
    };
    literature.secretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the SOPS-decrypted file containing literature/fanfic URLs (one per line)";
    };
    literature.downloadPath = lib.mkOption {
      type = lib.types.str;
      description = "Directory to download literature/fanfics into";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gallery-dl
      fanficfare
    ];

    sops.secrets = {
      "gallery-dl/ao3-username" = { };
      "gallery-dl/ao3-password" = { };
      "gallery-dl/mangas-urls" = { };
      "gallery-dl/literature-urls" = { };
    };

    sops.templates."fanficfare-personal.ini" = {
      owner = user;
      content = ''
        [archiveofourown.org]
        is_adult:true
        user = ${config.sops.placeholder."gallery-dl/ao3-username"}
        pass = ${config.sops.placeholder."gallery-dl/ao3-password"}
      '';
    };

    hjem.users.${user}.files = {
      ".config/gallery-dl/mangas.json".text = builtins.toJSON mangasConfig;
    };

    # --- Mangas (gallery-dl) ---
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
            --config /home/${user}/.config/gallery-dl/mangas.json \
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

    # --- Literature (FanFicFare) ---
    systemd.services.fanficfare-literature = {
      description = "FanFicFare AO3 Literature Updater";
      after = [ "network.target" ];
      path = with pkgs; [
        fanficfare
        gnugrep
        findutils
      ];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        ExecStart = pkgs.writeShellScript "fanficfare-literature-run" ''
          while IFS= read -r url; do
            # Skip empty lines and comments
            [[ -z "$url" || "$url" == \#* ]] && continue

            # Extract work ID from URL to find existing epub
            id=$(echo "$url" | grep -oP '\d{6,}')
            existing=$(find "${cfg.literature.downloadPath}" -name "*''${id}*" -name "*.epub" | head -1)

            if [[ -n "$existing" ]]; then
              # Update in place — only fetches new chapters
              ${pkgs.fanficfare}/bin/fanficfare \
                -c ${config.sops.templates."fanficfare-personal.ini".path} \
                --update-epub \
                --non-interactive \
                -o "output_filename=$existing" \
                "$url" || true
            else
              # First download
              ${pkgs.fanficfare}/bin/fanficfare \
                -c ${config.sops.templates."fanficfare-personal.ini".path} \
                --non-interactive \
                -o "output_filename=${cfg.literature.downloadPath}/\''${title}-\''${author}.epub" \
                "$url" || true
            fi
          done < "${cfg.literature.secretFile}"
        '';
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.timers.fanficfare-literature = {
      description = "FanFicFare literature — once a day";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
      };
    };
  };
}

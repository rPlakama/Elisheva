{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.features.library;
  user = config.core.user;
  kavitaPort = 3034;
  suwayomiPort = 4567;

  # --- gallery-dl Base Configurations ---
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
      mangadex = {
        lang = "pt-br";
        ratings = [
          "safe"
          "suggestive"
          "erotica"
        ];
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

  mkGalleryDlConfig = path: postprocessors:
    baseConfig
    // {
      extractor =
        baseConfig.extractor
        // {
          base-directory = path;
          archive = "${path}.archive.sqlite3";
          postprocessors = postprocessors;
        };
    };

  # Mangas get zipped into cbz archives
  mangasConfig = mkGalleryDlConfig cfg.gallery-dl.mangas.downloadPath [
    {
      name = "zip";
      extension = "cbz";
      mode = "after";
    }
    {
      name = "exec";
      command = "rm -rf \"{_directory}\"";
      mode = "after";
    }
  ];

  mangadexConfig = mkGalleryDlConfig cfg.gallery-dl.mangadex.downloadPath [
    {
      name = "zip";
      extension = "cbz";
      mode = "after";
    }
    {
      name = "exec";
      command = "rm -rf \"{_directory}\"";
      mode = "after";
    }
  ];
in {
  # --- Options ---
  options.features.library = {
    enable = lib.mkEnableOption "Library Master Switch";

    kavita = {
      enable = lib.mkEnableOption "Kavita self-hosted digital library";
    };

    suwayomi = {
      enable = lib.mkEnableOption "Suwayomi-Server (Tachidesk) manga reader";
    };

    gallery-dl = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "gallery-dl (manga) & FanFicFare (literature) downloader";
      };
      mangas = {
        secretFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to the SOPS-decrypted file containing manga URLs (one per line)";
        };
        downloadPath = lib.mkOption {
          type = lib.types.str;
          description = "Directory to download manga into";
        };
      };
      mangadex = {
        secretFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to the SOPS-decrypted file containing MangaDex URLs (one per line)";
        };
        downloadPath = lib.mkOption {
          type = lib.types.str;
          description = "Directory to download MangaDex manga into";
        };
      };
      literature = {
        secretFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to the SOPS-decrypted file containing literature/fanfic URLs (one per line)";
        };
        downloadPath = lib.mkOption {
          type = lib.types.str;
          description = "Directory to download literature/fanfics into";
        };
      };
    };
  };

  # --- Implementation ---
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Default sub-services to true if the master switch is active
      {
        features.library = {
          kavita.enable = lib.mkDefault true;
          suwayomi.enable = lib.mkDefault true;
          gallery-dl.enable = lib.mkDefault true;
        };
      }

      # 2. Kavita Configuration
      (lib.mkIf cfg.kavita.enable {
        sops.secrets."kavita/token" = {
          owner = "kavita";
        };

        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = ["/var/lib/kavita"];
          unifiedDNS.proxyServices = {
            kavita = kavitaPort;
          };
        };

        networking.firewall.allowedTCPPorts = [kavitaPort];
        systemd.services.kavita.serviceConfig.SupplementaryGroups = ["media"];

        services.kavita = {
          package = inputs.kavita-pkg.packages.${pkgs.stdenv.hostPlatform.system}.kavita;
          enable = true;
          tokenKeyFile = config.sops.secrets."kavita/token".path;
          settings.Port = kavitaPort;
        };
      })

      # 3. Suwayomi Configuration
      (lib.mkIf cfg.suwayomi.enable {
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = ["/var/lib/suwayomi-server"];
          unifiedDNS.proxyServices = {
            suwayomi = suwayomiPort;
          };
        };

        networking.firewall.allowedTCPPorts = [suwayomiPort];
        systemd.services.suwayomi-server.serviceConfig.SupplementaryGroups = ["media"];

        services.suwayomi-server = {
          enable = true;
          settings = {
            server.port = suwayomiPort;
          };
        };
      })

      # 4. gallery-dl / FanFicFare Configuration
      (lib.mkIf cfg.gallery-dl.enable {
        environment.systemPackages = with pkgs; [
          gallery-dl
          fanficfare
        ];

        sops.secrets = {
          "gallery-dl/ao3-username" = {};
          "gallery-dl/ao3-password" = {};
          "gallery-dl/mangas-urls" = {};
          "gallery-dl/mangadex-urls" = {};
          "gallery-dl/literature-urls" = {};
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
          ".config/gallery-dl/mangadex.json".text = builtins.toJSON mangadexConfig;
        };

        # --- Mangas (gallery-dl) Services ---
        systemd.services.gallery-dl-mangas = {
          description = "gallery-dl Manga Downloader";
          after = [
            "network.target"
            "flaresolverr.service"
          ];
          wants = ["flaresolverr.service"];
          path = with pkgs; [
            coreutils
            p7zip
            zip
          ];
          serviceConfig = {
            Type = "oneshot";
            User = user;
            ExecStart = pkgs.writeShellScript "gallery-dl-mangas-run" ''
              ${pkgs.gallery-dl}/bin/gallery-dl \
                --config /home/${user}/.config/gallery-dl/mangas.json \
                --input-file "${cfg.gallery-dl.mangas.secretFile}"
            '';
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };

        systemd.timers.gallery-dl-mangas = {
          description = "gallery-dl mangas — once a day";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "00:00";
            Persistent = true;
          };
        };

        # --- MangaDex (gallery-dl) Services ---
        systemd.services.gallery-dl-mangadex = {
          description = "gallery-dl MangaDex Downloader";
          after = ["network.target"];
          path = with pkgs; [
            coreutils
            p7zip
            zip
          ];
          serviceConfig = {
            Type = "oneshot";
            User = user;
            ExecStart = pkgs.writeShellScript "gallery-dl-mangadex-run" ''
              ${pkgs.gallery-dl}/bin/gallery-dl \
                --config /home/${user}/.config/gallery-dl/mangadex.json \
                --input-file "${cfg.gallery-dl.mangadex.secretFile}"
            '';
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };

        systemd.timers.gallery-dl-mangadex = {
          description = "gallery-dl MangaDex — once a day";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "02:00";
            Persistent = true;
          };
        };

        # --- Literature (FanFicFare) Services ---
        systemd.services.fanficfare-literature = {
          description = "FanFicFare AO3 Literature Updater";
          after = ["network.target"];
          path = with pkgs; [
            fanficfare
            gnugrep
            fd
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
                existing=$(fd -t f -g "*''${id}*.epub" "${cfg.gallery-dl.literature.downloadPath}" | head -n 1)

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
                    -o "output_filename=${cfg.gallery-dl.literature.downloadPath}/\''${title}-\''${author}.epub" \
                    "$url" || true
                fi
              done < "${cfg.gallery-dl.literature.secretFile}"
            '';
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };

        systemd.timers.fanficfare-literature = {
          description = "FanFicFare literature — once a day";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "01:00";
            Persistent = true;
          };
        };
      })
    ]
  );
}

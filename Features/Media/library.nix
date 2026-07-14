{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.features.library;
  kavitaPort = 3034;
  suwayomiPort = 4567;
  komgaPort = 3035;
  komfPort = 8085;
  domain = config.core.domain;

  komf = pkgs.stdenv.mkDerivation rec {
    pname = "komf";
    version = "1.7.1";

    src = pkgs.fetchurl {
      url = "https://github.com/Snd-R/komf/releases/download/${version}/komf-${version}.jar";
      hash = "sha256-reVCSNj4FlKILXSRuRw/m7uv/SjTXS0Ch1snrNWJBNE=";
    };

    nativeBuildInputs = [pkgs.makeWrapper];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin $out/share/java
      cp $src $out/share/java/komf.jar
      makeWrapper ${pkgs.jdk}/bin/java $out/bin/komf \
        --add-flags "-jar $out/share/java/komf.jar"
    '';

    meta = with pkgs.lib; {
      description = "Komga and Kavita metadata fetcher for mangas and novels";
      homepage = "https://github.com/Snd-R/komf";
      license = licenses.mit;
      platforms = platforms.all;
      mainProgram = "komf";
    };
  };
in {
  options.features.library = {
    enable = lib.mkEnableOption "Library Master Switch";
    downloadPath = lib.mkOption {
      type = lib.types.str;
      default = "/media/literature/mangas";
      description = "Download path for library downloads";
    };
    kavita.enable = lib.mkEnableOption "Kavita self-hosted digital library";
    suwayomi.enable = lib.mkEnableOption "Suwayomi-Server (Tachidesk) manga reader";
    komga.enable = lib.mkEnableOption "Komga + komf metadata resolver";
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        features = {
          preservation.system.directories = [cfg.downloadPath];
        };
        features.library = {
          kavita.enable = lib.mkDefault true;
          suwayomi.enable = lib.mkDefault true;
          komga.enable = lib.mkDefault true;
        };
      }
      (lib.mkIf cfg.kavita.enable {
        sops.secrets."kavita/token" = {
          owner = "kavita";
        };
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = ["/var/lib/kavita"];
          unifiedDNS.proxyServices.kavita = kavitaPort;
        };
        networking.firewall.allowedTCPPorts = [kavitaPort];
        systemd.services.kavita.serviceConfig.SupplementaryGroups = ["media"];
        services.kavita = {
          enable = true;
          tokenKeyFile = config.sops.secrets."kavita/token".path;
          settings.Port = kavitaPort;
        };
      })
      (lib.mkIf cfg.suwayomi.enable {
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = ["/var/lib/suwayomi-server"];
          unifiedDNS.proxyServices.suwayomi = suwayomiPort;
        };
        networking.firewall.allowedTCPPorts = [suwayomiPort];
        systemd.services.suwayomi-server.serviceConfig.SupplementaryGroups = ["media"];
        services.suwayomi-server = {
          enable = true;
          settings = {
            server = {
              port = suwayomiPort;
              downloadAsCbz = true;
              downloadsPath = cfg.downloadPath;
              extensionRepos = [
                "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
                "https://raw.githubusercontent.com/yuzono/manga-repo/repo/index.min.json"
              ];
            };
          };
        };
      })
      (lib.mkIf cfg.komga.enable {
        features = {
          mediaPermissions.enable = true;
          preservation.system.directories = [
            "/var/lib/komga"
            "/var/lib/komf"
          ];
          unifiedDNS.proxyServices = {
            komga = komgaPort;
            komf = komfPort;
          };
        };
        networking.firewall.allowedTCPPorts = [
          komgaPort
          komfPort
        ];
        systemd.services.komga = {
          path = [pkgs.p7zip];
          serviceConfig.SupplementaryGroups = ["media"];
        };
        # pkgs.komga comes from nixpkgs-master overlay (Komga 1.25+)
        services.komga = {
          enable = true;
          settings = {
            server.port = komgaPort;
            komga.cors.allowed-origins = [
              "https://komf.${domain}"
            ];
          };
        };
        systemd.services.komf = {
          description = "Komf metadata resolver";
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            User = "komf";
            Group = "media";
            Type = "simple";
            Restart = "on-failure";
            ExecStart = "${komf}/bin/komf";
            StateDirectory = "komf";
            WorkingDirectory = "/var/lib/komf";
            RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
          };
        };
        users.users.komf = {
          group = "media";
          isSystemUser = true;
        };
      })
    ]
  );
}

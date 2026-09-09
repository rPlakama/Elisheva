{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let

  featureCall = config.features;

  #nix shell nixpkgs#packwiz
  baselineModsDir = ./baseline-mods;
  additionalsDir = ./additionals;

  baselineMods = pkgs.fetchPackwizModpack {
    url = "file://${baselineModsDir}/pack.toml";
    packHash = "sha256-nhV+H1L6L4aXEm+WYo1ETLfge+OODogX8PwO1As/UXE=";
  };

  additionals = pkgs.fetchPackwizModpack {
    url = "file://${additionalsDir}/pack.toml";
    packHash = "sha256-9srKmZx4f4neLRkVuf2L/8eoiYj0bQiwyC8YmUkWPYE=";
  };

  modpack = pkgs.symlinkJoin {
    name = "moontier-modpack";
    paths = [ baselineMods additionals ];
  };

in

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.features.minecraft-server.enable = lib.mkEnableOption "Minecraft server";

  config = lib.mkIf featureCall.minecraft-server.enable {
    nixpkgs.overlays = lib.mkBefore [ inputs.nix-minecraft.overlay ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 43000 ];

    environment.systemPackages = with pkgs; [
      tmux
    ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      # dataDir = "/srv/minecraft";

      servers.moontier = {
        enable = true;
        # package = pkgs.paperServers.paper-26_2;
        # fabric requires java 25 for fabric-26_2
        package = pkgs.fabricServers.fabric-26_2.override {
          jre_headless = pkgs.openjdk25_headless;
        };
        openFirewall = true;

        symlinks = {
          "mods" = "${modpack}/mods";
        };

        serverProperties = {
          server-port = 43000;
          difficulty = 3;
          online-mode = false;
          gamemode = 0;
          max-players = 5;
          view-distance = 8;
          simulation-distance = 6;
          motd = "Moontier Minecraft Server";
          white-list = false;
          enable-rcon = true;
          "rcon.password" = "moontier";
        };
        jvmOpts = "-Xms1G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Dcom.mojang.eula.agree=true -XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
      };
    };
  };
}

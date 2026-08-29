{
  pkgs,
  config,
  lib,
  ...
}:
let

  featureCall = config.features;

in

{

  options.features.minecraft-server.enable = lib.mkEnableOption "Minecraft server";

  config = lib.mkIf featureCall.minecraft-server.enable {

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 43000 ];

    services.minecraft-server = {
      enable = true;
      eula = true;
      package = pkgs.papermc;
      openFirewall = true; # local

      serverProperties = {
        server-port = 43000;
        difficulty = 3;
        online-mode = false;
        gamemode = 0;
        max-players = 5;
        motd = "Moontier Minecraft Server";
        white-list = true;
        enable-rcon = true;
        "rcon.password" = "moontier";
      };
      jvmOpts = "-Xms3069M -Xmx3069M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Dcom.mojang.eula.agree=true -XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
    };
  };

}

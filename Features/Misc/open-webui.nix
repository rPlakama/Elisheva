{
  config,
  lib,
  ...
}: let
  cfg = config.features.open-webui;
  Port = 1111;
in {
  options.features.open-webui.enable = lib.mkEnableOption "Open-webui, local LLM-ui";

  config = lib.mkIf cfg.enable {
    features = {
      unifiedDNS.proxyServices.open-webui = Port;
    };

    services.open-webui = {
      enable = true;
      openFirewall = true;
				port = Port;
    };
  };
}

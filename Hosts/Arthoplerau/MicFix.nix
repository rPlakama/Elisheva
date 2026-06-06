{ ... }:
{
  services.pipewire.wireplumber.extraConfig = {
    "10-alsa-fallback" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "device.name" = "~alsa_card.*"; }
          ];
          actions = {
            update-props = {
              "api.alsa.use-ucm" = false;
            };
          };
        }
        {
          matches = [
            { "node.name" = "~alsa_input.*"; }
          ];
          actions = {
            update-props = {
              "audio.format" = "S32_LE";
              "audio.rate" = 48000;
              "audio.channels" = 2;
            };
          };
        }
      ];
    };
  };
}

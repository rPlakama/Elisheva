{ config, lib, ... }:
let
  cfg = config.features.bluetooth-injct;
in
{
  options.features.bluetooth-injct.enable = lib.mkEnableOption "Bluetooth device delay opt ";

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      extraConfig.pipewire."92-sample-rates" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [
            44100
            48000
          ];
          "default.clock.min-quantum" = 512; # BT gains little from tiny quanta / test
        };
      };

      wireplumber.extraConfig."51-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = [
            "ldac"
            "aptx_hd"
            "aptx"
            "aac"
            "sbc_xq"
            "sbc"
          ];
        };

        "monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions.update-props = {
              "bluez5.a2dp.ldac.quality" = "mq"; # 330 kbps
            };
          }
          {
            matches = [ { "node.name" = "~bluez_output.*"; } ];
            actions.update-props = {
              "session.suspend-timeout-seconds" = 0; # no pop/delay when audio resumes
              "node.pause-on-idle" = false;
            };
          }
        ];
      };
    };
  };
}

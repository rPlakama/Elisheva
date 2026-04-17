{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.suwayomi;
in

{
  options.optionals.features.suwayomi.enable = lib.mkOption {
    type = lib.types.bool;
    description = "Suwayomi Configuration";
    default = true;
  };
  config = lib.mkIf cfg.enable {
    core.features.mediaPermissions.enable = true;
    services.suwayomi-server = {
      enable = true;
      group = "media";
      openFirewall = true;
      settings.server = {
        port = 6721;
        extensionRepos = [
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        ];
      };
    };
  };
}

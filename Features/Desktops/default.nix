{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  contents = builtins.readDir ./.;
  isImportable = name: type:
    (type == "directory") || (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix");
  importable = lib.filterAttrs (name: type: isImportable name type) contents;
  modulePaths = lib.mapAttrsToList (name: _: ./${name}) importable;

  headless = config.core.headless;
  theming = config.features.theming;
  noctaliaGreeter = config.features.noctalia.enable && !headless;
in {
  imports = modulePaths ++ [ inputs.noctalia-greeter.nixosModules.default ];

  boot.consoleLogLevel = 0;

  services.displayManager.ly = {
    enable = !headless && !noctaliaGreeter;
    settings = {
      default_input = "password";
      bigclock = true;
      hide_borders = true;
    };
  };

  services.greetd.settings = lib.mkIf noctaliaGreeter {
    terminal.vt = 1;
    default_session.user = lib.mkDefault "greeter";
  };

  services.displayManager.noctalia-greeter = lib.mkIf noctaliaGreeter {
    enable = true;
    passwordless-sync-users = [ config.core.user ];
    cursorTheme.package = pkgs.volantes-cursors;
    settings = {
      session.default = "niri";
      user.default = config.core.user;
      cursor = {
        theme = theming.cursorTheme;
        size = theming.cursorSize;
      };
      appearance = {
        scheme = "Synced";
        password_style = "random";
        theme_mode = if theming.darkTheme then "dark" else "light";
        font_family = theming.fontFamily;
      };
    };
  };
}

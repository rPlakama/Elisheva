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
  kde = config.features.kdeDesktop.enable;
  gnome = config.features.gnomeDesktop.enable;
  niri = config.features.niri.enable;
  desktopManager = kde || gnome;
  noctaliaGreeter = config.features.noctalia.enable && !headless && !desktopManager;
in {
  imports = modulePaths ++ [ inputs.noctalia-greeter.nixosModules.default ];

  assertions = [
    {
      assertion = !(kde && gnome);
      message = "features.kdeDesktop and features.gnomeDesktop cannot be enabled at the same time";
    }
  ];

  boot.consoleLogLevel = 0;

  services.displayManager.ly = {
    enable = !headless && !desktopManager && !noctaliaGreeter;
    settings = {
      default_input = "password";
      bigclock = true;
      hide_borders = true;
    };
  };

  services.displayManager.sddm = lib.mkIf (!headless && kde) {
    enable = true;
  };

  services.displayManager.gdm.enable = !headless && gnome;

  services.displayManager.defaultSession = lib.mkIf (kde && niri) (lib.mkForce "niri");

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

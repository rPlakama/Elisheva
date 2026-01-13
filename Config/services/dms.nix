{ inputs, ... }:
{

  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    plugins = {
      mediaPlayer.enable = true;
    };
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  services.displayManager.dms-greeter = {
    compositor = {
      name = "niri";
    };

    # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
    configHome = "/home/rplakama";
  };

}

{ inputs, ... }:
{

  imports = [
    inputs.dms.nixosModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  services.displayManager.dms-greeter = {
    compositor = {
      name = "niri";
    };
    configHome = "/home/rplakama";
  };

}

{
  pkgs,
  config,
  ...
}: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
    polarity = "dark";
    targets.qt.enable = true;
    targets.plymouth.enable = false;

    fonts = {
      sizes.terminal = 9;
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      emoji = config.stylix.fonts.monospace;
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Mono";
      };
    };

    override = {
      base00 = "101010";
    };
  };
}

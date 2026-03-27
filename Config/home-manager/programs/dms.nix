{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.danksearch.homeModules.dsearch
    inputs.dms.homeModules.niri
  ];
  programs = {
    dsearch.enable = true;
    dank-material-shell = {
      enable = true;
      niri.includes = {
        enable = true;
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "windowrules"
          "alttab"
          "binds"
          "colors"
          "layout"
          "outputs"
          "wpblur"
          "cursor"
        ];
      };
    };
  };
}

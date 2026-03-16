{ isDesktop, ... }:
{
  programs = {
    dsearch.enable = true;
    dank-material-shell = {
      enable = isDesktop;
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

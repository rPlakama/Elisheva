{ osConfig, ... }:
{
  programs.dank-material-shell = {
    enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
    niri.includes = {
      enable = true;
      override = true;
      originalFileName = "hm";
      filesToInclude = [
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
}

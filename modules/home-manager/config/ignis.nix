# home.nix
{ inputs, pkgs, ... }:
{
  programs.ignis = {
    enable = true;

    addToPythonEnv = true; # Lsp Support

    configDir = ./ignis.nix;

    services = {
      bluetooth.enable = true;
      recorder.enable = true;
      audio.enable = true;
      network.enable = true;
    };

    # Enable Sass support
    sass = {
      enable = true;
      useDartSass = true;
    };

    # Extra packages available at runtime
    # These can be regular packages or Python packages
    extraPackages = with pkgs; [
      python313Packages.jinja2
      python313Packages.materialyoucolor
      python313Packages.pillow
    ];
  };
}

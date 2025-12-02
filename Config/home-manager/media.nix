{pkgs, ...}: {
  programs = {
    mpv = {
      enable = true;
      scripts = with pkgs; [mpvScripts.mpris];
      config = {
        save-position-on-quit = true;
      };
    };
    zathura = {
      enable = true;
      extraConfig = ''
        set selection-clipboard clipboard
      '';
    };
  };
}

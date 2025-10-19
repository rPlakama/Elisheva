{pkgs, ...}: {
  programs.anyrun = {
    enable = true;
    config = {
      x = {fraction = 0.5;};
      y = {fraction = 0.0;};
      width = {fraction = 0.3;};
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;

      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
      ];
    };

    extraCss =
      /*
      css
      */
      ''
        .some_class {
          background: red;
        }
      '';
  };
}

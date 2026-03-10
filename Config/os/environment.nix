{ ... }:
{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MANPAGER = "nvim +Man!";
      _JAVA_AWT_WM_NONREPARENTING = 1;
      STUDIO_VM_OPTIONS = "-Dwayland.enabled=true";
    };
    shellAliases = {
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}

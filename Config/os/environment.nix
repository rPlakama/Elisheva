{ ... }:
{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MANPAGER = "nvim +Man!";
    };
    shellAliases = {
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}

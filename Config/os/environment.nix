{ ... }:
{
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MANPAGER = "hx +Man!";
    };
    shellAliases = {
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}

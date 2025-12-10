{...}: {
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shellAliases = {
      develop = "nix develop ./.nix-develop-cache-1-link";
      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
}

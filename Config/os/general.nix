{ pkgs, config, ... }:
{
  # Locale
  console.keyMap = if config.networking.hostName == "Elisheva" then "br-abnt" else "us";
  time.timeZone = "America/Recife";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  # Env
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MANPAGER = "nvim +Man!";
    };
    shellAliases = {

      sfs = "echo -e 'Rebuild Type: \\033[32m SWITCH \\033[0m'; sudo nixos-rebuild switch --flake .#$HOSTNAME";
      sfb = "echo -e 'Rebuild Type: \\033[32m BOOT \\033[0m'; sudo nixos-rebuild boot --flake .#$HOSTNAME";
      sft = "echo -e 'Rebuild Type: \\033[32m TEST \\033[0m'; sudo nixos-rebuild test --flake .#$HOSTNAME";
      nf = "echo -e 'Checking for: \\033[32m FLAKE \\033[0m'; nix flake check .#$HOSTNAME";

      cl = "echo -e 'Cleaning Type: \\033[32m SIMPLE \\033[0m'; sudo nix store gc;";
      cla = "echo -e 'Cleaning Type: \\033[32m ALL \\033[0m'; sudo nix-collect-garbage -d; nix-collect-garbage; nix-store --optimise";

      develop = "nix develop ./.nix-develop-cache-1-link";
      nv = "nvim";

      "..." = "cd ../../";
      "...." = "cd ../../../";
    };
  };
  # Others
  nix.package = pkgs.lix;
  security.sudo-rs.enable = true;

}

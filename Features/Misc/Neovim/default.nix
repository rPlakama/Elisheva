{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.neovim;
  headless = config.core.headless;
in
{
  options.features.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Neovim Configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${config.core.user} = {
      environment.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        MANPAGER = "nvim +Man!";
      };

      packages = with pkgs; [
        typst
        luaformatter
        nixfmt
      ];
    };

    programs.nixvim = {
      enable = true;
      imports = [
        ./settings.nix
        ./plugins.nix
        (import ./lsp.nix { inherit headless; })
        ./keymaps.nix
      ];
    };
  };
}

{ config, lib, pkgs, ... }:
let
  cfg = config.features.neovim;
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
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };

    environment.systemPackages = with pkgs; [
      typst
      luaformatter
      nixfmt
    ];

    programs.nixvim = {
      enable = true;
      imports = [
        ./settings.nix
        ./plugins.nix
        ./lsp.nix
        ./keymaps.nix
      ];
    };
  };
}

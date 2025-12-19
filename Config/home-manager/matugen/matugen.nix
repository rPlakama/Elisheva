{ config, pkgs, ... }:

let
  tomlFormat = pkgs.formats.toml {};
  matugenConfig = tomlFormat.generate "config.toml" {
    config = {};
    templates.neovim_lua = {
      input_path = "${config.home.homeDirectory}/.config/matugen/template/neovim.lua";
      output_path = "${config.home.homeDirectory}/.config/nvim/lua/plugins/dankcolors.lua";
    };
  };
in
{
  xdg.configFile."matugen/config.toml".source = matugenConfig;

  xdg.configFile."matugen/template/neovim.lua".source =
    config.lib.file.mkOutOfStoreSymlink ./template/neovim.lua;

}

{ ... }:

{
  programs.nixvim.plugins = {
    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          python = [ "isort" "black" ];
          go = [ "gofmt" ];
          nix = [ "nixfmt" ];
          javascript = [ "prettierd" ];
          typescript = [ "prettierd" ];
          "*" = [ "codespell" ];
        };
      };
    };
  };
}

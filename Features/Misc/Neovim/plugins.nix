{ pkgs, ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    };

    gitsigns = {
      enable = true;
      settings = {
        signs_staged_enable = true;
        signcolumn = true;
        numhl = false;
        linehl = false;
        word_diff = false;
        watch_gitdir = {
          follow_files = true;
        };
        auto_attach = true;
        attach_to_untracked = false;
        current_line_blame = false;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "eol";
          delay = 1000;
          ignore_whitespace = false;
          virt_text_priority = 100;
          use_focus = true;
        };
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>";
        sign_priority = 6;
        update_debounce = 100;
        max_file_length = 40000;
        preview_config = {
          style = "minimal";
          relative = "cursor";
          row = 0;
          col = 1;
        };
      };
    };

    oil = {
      enable = true;
      settings = {
        default_file_explorer = true;
        columns = [
          "icon"
          "mtime"
        ];
        buf_options = {
          buflisted = false;
          bufhidden = "hide";
        };
        win_options = {
          wrap = false;
          signcolumn = "no";
          cursorcolumn = true;
          foldcolumn = "0";
          spell = false;
          list = false;
          conceallevel = 3;
          concealcursor = "nvic";
        };
        delete_to_trash = false;
        skip_confirm_for_simple_edits = false;
        prompt_save_on_select_new_entry = true;
        cleanup_delay_ms = 2000;
        lsp_file_methods = {
          enabled = true;
          timeout_ms = 1000;
          autosave_changes = false;
        };
        constrain_cursor = "editable";
        watch_for_changes = false;
        use_default_keymaps = true;
        view_options = {
          show_hidden = true;
          is_hidden_file.__raw = ''
            function(name, bufnr)
              return name:match("^%.") ~= nil
            end
          '';
          is_always_hidden.__raw = ''
            function(name, bufnr)
              return false
            end
          '';
          natural_order = "fast";
          case_insensitive = false;
          sort = [
            { __raw = ''{"type", "asc"}''; }
            { __raw = ''{"name", "asc"}''; }
          ];
        };
      };
    };

    flash.enable = true;
    fzf-lua.enable = true;

    blink-indent = {
      enable = true;
      settings = {
        dedent_scoped_filetypes = {
          include_defaults = true;
        };
        blocked = {
          buftypes = {
            include_defaults = true;
          };
          filetypes = {
            include_defaults = true;
          };
        };
        mappings = {
          border = "both";
          object_scope = "ii";
          object_scope_with_border = "ai";
          goto_top = "[i";
          goto_bottom = "]i";
        };
        static = {
          enabled = true;
          char = "▎";
          priority = 1;
          highlights = [ "BlinkIndent" ];
        };
        scope = {
          enabled = true;
          indent_at_cursor = false;
          char = "▎";
          priority = 1000;
          highlights = [
            "BlinkIndentOrange"
            "BlinkIndentViolet"
            "BlinkIndentBlue"
          ];
          underline = {
            enabled = false;
            highlights = [
              "BlinkIndentOrangeUnderline"
              "BlinkIndentVioletUnderline"
              "BlinkIndentBlueUnderline"
            ];
          };
        };
      };
    };
  };
}

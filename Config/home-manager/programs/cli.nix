{ osConfig, ... }:
{
  programs = {

    fish = {
      enable = true;
      shellInit = ''
        function fish_greeting
        end
        fish_vi_key_bindings
      '';
    };

    foot = {
      enable = osConfig.networking.hostName == "Centuria" || osConfig.networking.hostName == "Elisheva";
      settings.main = {
        dpi-aware = false;
        font = "CaskaydiaCove Nerd Font Mono:size=9";
        include = "/home/rplakama/.config/foot/dank-colors.ini";
      };
    };

    fzf.enable = true;

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        format = "$username$hostname$directory$git_branch$git_commit$git_state$git_status$aws$buf$bun$c$cmake$conda$cpp$crystal$dart$deno$docker_context$elixir$elm$fennel$gcloud$golang$gradle$guix_shell$haskell$haxe$java$julia$kotlin$lua$memory_usage$nim$nix_shell$nodejs$ocaml$python$rust$scala$swift$zig$jobs$cmd_duration$shell$character";

        # Base
        directory.read_only = " 󰀼 ";
        hostname.ssh_symbol = " ";
        username.show_always = true;
        cmd_duration = { };
        jobs = { };

        character = {
          success_symbol = "[](white)";
          error_symbol = "[](red)";
          vimcmd_symbol = "[](green)";
          vimcmd_visual_symbol = "[ ](green)";
          vimcmd_replace_symbol = "[](purple)";
          vimcmd_replace_one_symbol = "[](purple)";
        };

        shell = {
          disabled = true;
          fish_indicator = " ";
          nu_indicator = " >";
          bash_indicator = " 󱆃";
        };

        nix_shell = {
          impure_msg = "[impure](bold red)";
          pure_msg = "[pure](bold green)";
          unknown_msg = "[unknown shell](bold yellow)";
          symbol = " ";
          format = "via [$symbol$state](bold blue) ";
        };

        # Git
        git_branch.symbol = " ";
        git_commit.tag_symbol = "  ";
        fossil_branch.symbol = " ";
        hg_branch.symbol = " ";

        # Language & Tool Symbols
        aws.symbol = "  ";
        buf.symbol = "  ";
        bun.symbol = " ";
        c.symbol = " ";
        cmake.symbol = " ";
        conda.symbol = " ";
        cpp.symbol = " ";
        crystal.symbol = " ";
        dart.symbol = " ";
        deno.symbol = " ";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fennel.symbol = " ";
        gcloud.symbol = "  ";
        golang.symbol = " ";
        gradle.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        kotlin.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = "󰍛 ";
        nim.symbol = " ";
        nodejs.symbol = " ";
        ocaml.symbol = " ";
        python.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        swift.symbol = " ";
        zig.symbol = " ";
      };
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        mgr.show_hidden = true;
        opener.edit = [
          { run = "nvim \"$@\""; block = true; }
        ];
      };
      keymap.mgr.prepend_keymap = [
        {
          on = [ "<C-n>" ];
          run = "shell 'ripdrag -H 80 \"$@\" -x 2>/dev/null &' --confirm";
        }
      ];
    };

  };
}

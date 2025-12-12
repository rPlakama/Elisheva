{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      format = "$username$hostname$directory$git_branch$git_commit$git_state$git_status$aws$buf$bun$c$cmake$conda$cpp$crystal$dart$deno$docker_context$elixir$elm$fennel$gcloud$golang$gradle$guix_shell$haskell$haxe$java$julia$kotlin$lua$memory_usage$nim$nix_shell$nodejs$ocaml$python$rust$scala$swift$zig$jobs$cmd_duration$shell$character";

      character = {
        success_symbol = "[](white)";
        error_symbol = "[](red)";
        vimcmd_symbol = "[](green)";
        vimcmd_visual_symbol = "[ ](green)";
        vimcmd_replace_symbol = "[](purple)";
        vimcmd_replace_one_symbol = "[](purple)";
      };

      directory = {
        read_only = " 󰀼 ";
      };

      shell = {
        disabled = true;
        fish_indicator = " ";
        nu_indicator = " >";
        bash_indicator = " 󱆃";
      };

      username = {
        show_always = true;
      };

      hostname = {
        ssh_symbol = " ";
      };

      cmd_duration = { };
      jobs = { };
      memory_usage = {
        symbol = "󰍛 ";
      };

      aws = {
        symbol = "  ";
      };
      docker_context = {
        symbol = " ";
      };
      gcloud = {
        symbol = "  ";
      };

      buf = {
        symbol = "  ";
      };
      bun = {
        symbol = " ";
      };
      c = {
        symbol = " ";
      };
      cmake = {
        symbol = " ";
      };
      conda = {
        symbol = " ";
      };
      cpp = {
        symbol = " ";
      };
      crystal = {
        symbol = " ";
      };
      dart = {
        symbol = " ";
      };
      deno = {
        symbol = " ";
      };
      elixir = {
        symbol = " ";
      };
      elm = {
        symbol = " ";
      };
      fennel = {
        symbol = " ";
      };
      golang = {
        symbol = " ";
      };
      gradle = {
        symbol = " ";
      };
      guix_shell = {
        symbol = " ";
      };
      haskell = {
        symbol = " ";
      };
      haxe = {
        symbol = " ";
      };
      java = {
        symbol = " ";
      };
      julia = {
        symbol = " ";
      };
      kotlin = {
        symbol = " ";
      };
      lua = {
        symbol = " ";
      };
      nim = {
        symbol = " ";
      };
      nodejs = {
        symbol = " ";
      };
      ocaml = {
        symbol = " ";
      };
      python = {
        symbol = " ";
      };
      rust = {
        symbol = " ";
      };
      scala = {
        symbol = " ";
      };
      swift = {
        symbol = " ";
      };
      zig = {
        symbol = " ";
      };

      git_branch = {
        symbol = " ";
      };
      git_commit = {
        tag_symbol = "  ";
      };
      fossil_branch = {
        symbol = " ";
      };
      hg_branch = {
        symbol = " ";
      };

      nix_shell = {
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
        unknown_msg = "[unknown shell](bold yellow)";
        symbol = " ";
        format = "via [$symbol$state](bold blue) ";
      };
    };
  };
}

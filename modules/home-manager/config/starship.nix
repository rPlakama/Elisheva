{...}: {
  # -- Shell Decoration -- #
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      format = "$username$directory$git_branch$git_commit$git_state$git_status$c$elixir$elm$golang$gradle$haskell$java$julia$nodejs$nim$rust$scala$docker_context$jobs$cmd_duration$character";

      shell = {
        disabled = false;
        fish_indicator = " ";
        nu_indicator = " >";
        bash_indicator = " 󱆃";
      };

      character = {
        success_symbol = "";
        error_symbol = "";
        vimcmd_symbol = "";
        vimcmd_visual_symbol = " ";
      };

      username = {
        show_always = true;
      };

      aws = {
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

      cpp = {
        symbol = " ";
      };

      cmake = {
        symbol = " ";
      };

      conda = {
        symbol = " ";
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

      directory = {
        read_only = " 󰀼 ";
      };

      docker_context = {
        symbol = " ";
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

      fossil_branch = {
        symbol = " ";
      };

      gcloud = {
        symbol = "  ";
      };

      git_branch = {
        symbol = " ";
      };

      git_commit = {
        tag_symbol = "  ";
      };

      golang = {
        symbol = " ";
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

      hg_branch = {
        symbol = " ";
      };

      hostname = {
        ssh_symbol = " ";
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

      memory_usage = {};

      nix_shell = {
        symbol = " ";
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

      gradle = {
        symbol = " ";
      };
    };
  };
}

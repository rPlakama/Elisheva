function fish_greeting
end
fish_vi_key_bindings
function fish_prompt
    set -l nix_indicator ""

    if set -q IN_NIX_SHELL
        if test "$IN_NIX_SHELL" = pure
            set nix_indicator (set_color cyan)" pure "(set_color normal)
        else
            set nix_indicator (set_color cyan)" nix "(set_color normal)
        end
    else if set -q DIRENV_DIR
        set nix_indicator (set_color cyan)" direnv "(set_color normal)
    end

    echo -s (set_color normal) (hostname) " " (set_color blue) (prompt_pwd) (set_color normal) (fish_git_prompt) " " $nix_indicator
    echo -n " > "
end

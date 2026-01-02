{ ... }:

{

  home.file."Music/music.sh" = {
    executable = true;
    text = ''
          #!/usr/bin/env fish

      set -x FZF_DEFAULT_OPTS "--layout=reverse --border"

      while true
          set selected (fd . --exact-depth 2 --type d | fzf \
              -m \
              --preview 'ls -1 {}' \
              --prompt 'Play > ')

          if test -z "$selected"
              break
          end

          clear

          mpv \
      	--no-save-position-on-quit \
              --term-osd-bar \
              --gapless-audio=yes \
              --replaygain=album \
              $selected
      end

    '';
  };
}

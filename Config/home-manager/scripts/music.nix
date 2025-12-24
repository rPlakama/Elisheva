{ ... }:

{

  home.file."Music/music.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env fish
      cd ~/Music || exit

      set -x FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"

      while true
          set selected (fd . --exact-depth 2 --type d | fzf \
              -m \
              --preview 'ls -1 {}' \
              --header 'TAB to queue, ENTER to play' \
              --prompt 'Album > ')

          if test -z "$selected"
              break
          end

          clear

          mpv \
              --no-video \
              --no-save-position-on-quit \
              --term-osd-bar \
              --gapless-audio=weak \
              --replaygain=album \
              $selected
      end
    '';
  };
}

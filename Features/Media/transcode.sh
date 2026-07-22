#!/usr/bin/env bash
set -euo pipefail

MUSIC_DIR="${1:-/media/music/library}"
JOBS=$(( $(nproc) / 2 ))
[ "$JOBS" -lt 1 ] && JOBS=1

fd -0 -e flac --full-path "$MUSIC_DIR" | xargs -0 -P "$JOBS" -I{} sh -c '
  flac="$1"
  opus="${flac%.flac}.opus"
  if [ -f "$opus" ]; then
    exit 0
  fi
  ffmpeg -y -i "$flac" -c:a libopus -b:a 510k -vbr on -compression_level 10 -application audio "$opus" 2>/dev/null || {
    echo "[SKIP] Corrupted: $flac" >&2
    rm -f "$opus"
    exit 0
  }
  chmod 664 "$opus"
' _ {}

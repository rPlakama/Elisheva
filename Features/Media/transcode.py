#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from datetime import datetime
from multiprocessing import Pool, cpu_count
from pathlib import Path

# ── Configuration ────────────────────────────────────────────────────────────
# @MUSIC_DIR@ is substituted by Nix at build time (builtins.replaceStrings)

MUSIC_DIR_DEFAULT = "@MUSIC_DIR@"

# ── Logging ──────────────────────────────────────────────────────────────────

def log(msg):
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}", flush=True)


def _safe_chmod(path, mode):
    try:
        os.chmod(path, mode)
    except PermissionError:
        pass


# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1: FLAC → Opus Transcoding
# ═══════════════════════════════════════════════════════════════════════════════

def transcode_single(flac_path_str):
    """Transcode one FLAC to Opus. Returns (path, status)."""
    flac_path = Path(flac_path_str)
    opus_path = flac_path.with_suffix(".opus")
    if opus_path.exists():
        return (flac_path_str, "skip")
    try:
        result = subprocess.run(
            ["ffmpeg", "-y", "-i", str(flac_path),
             "-c:a", "libopus", "-b:a", "512k", "-vbr", "on",
             "-compression_level", "10", "-application", "audio",
             str(opus_path)],
            capture_output=True, timeout=600, stdin=subprocess.DEVNULL,
        )
        if result.returncode != 0:
            opus_path.unlink(missing_ok=True)
            return (flac_path_str, "error")
        _safe_chmod(opus_path, 0o664)
        return (flac_path_str, "ok")
    except Exception as e:
        opus_path.unlink(missing_ok=True)
        return (flac_path_str, f"error: {e}")


def run_transcode(music_dir):
    """Find all FLACs and transcode to Opus in parallel."""
    log("═══ Phase 1: FLAC → Opus Transcoding ═══")
    flacs = []
    for dirpath, _, filenames in os.walk(music_dir):
        for f in filenames:
            if f.lower().endswith(".flac"):
                flacs.append(os.path.join(dirpath, f))

    if not flacs:
        log("  No FLAC files found.")
        return

    log(f"  Found {len(flacs)} FLAC files")
    jobs = max(1, cpu_count() // 2)
    stats = {"skip": 0, "ok": 0, "error": 0}

    with Pool(processes=jobs) as pool:
        for path, status in pool.imap_unordered(transcode_single, flacs):
            key = status if status in stats else "error"
            stats[key] += 1
            if status == "ok":
                log(f"  Transcoded: {Path(path).name}")
            elif status not in ("skip",):
                log(f"  Failed: {Path(path).name} → {status}")

    log(f"  Transcode done: {json.dumps(stats)}")

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2: Stale FLAC Cleanup
# ═══════════════════════════════════════════════════════════════════════════════

def run_flac_cleanup(music_dir):
    """Remove FLACs that have a corresponding .opus sibling."""
    log("═══ Phase 2: Stale FLAC Cleanup ═══")
    removed = 0
    kept = 0
    for dirpath, _, filenames in os.walk(music_dir):
        dirpath = Path(dirpath)
        flacs = [f for f in filenames if f.lower().endswith(".flac")]
        for flac_name in flacs:
            flac_path = dirpath / flac_name
            opus_path = flac_path.with_suffix(".opus")
            if opus_path.exists() and opus_path.stat().st_size > 1024:
                flac_path.unlink()
                log(f"  Removed: {flac_path.relative_to(music_dir)}")
                removed += 1
            else:
                kept += 1
    log(f"  Cleanup done: {removed} removed, {kept} kept (no opus sibling)")

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    default_dir = MUSIC_DIR_DEFAULT if "@" not in MUSIC_DIR_DEFAULT else "/media/music/library"
    music_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(default_dir)
    if not music_dir.exists():
        log(f"Music directory does not exist: {music_dir}")
        sys.exit(1)

    log(f"FLAC→Opus Transcoder starting — {music_dir}")

    run_transcode(music_dir)
    run_flac_cleanup(music_dir)

    log("All phases complete.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Elisheva Lyrics Daemon — fetches synced .lrc lyrics from LRCLIB."""

import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

LRCLIB_API = "https://lrclib.net/api"
USER_AGENT = "ElishevaLyricsDaemon/1.0"
REQUEST_DELAY = 0.6

AUDIO_EXTS = {".flac", ".opus"}
DIRTY_TITLE_RE = re.compile(
    r"\s*[\(\[].*?(?:feat\.?|ft\.?|featuring|bonus track|remaster(?:ed)?|"
    r"live|demo|acoustic|instrumental|radio edit|extended|deluxe|"
    r"anniversary|explicit|clean|version).*?[\)\]]\s*",
    re.IGNORECASE,
)
YEAR_RE = re.compile(r"\s*[\(\[\.\-]?\s*(?:\d{4}|20\d{2})\s*[\)\]\.]?\s*$")


def log(msg):
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}", flush=True)


def get_tags(filepath):
    try:
        result = subprocess.run(
            [
                "ffprobe", "-v", "quiet", "-print_format", "json",
                "-show_entries",
                "format_tags=artist,album,album_artist,title:"
                "stream_tags=artist,album,album_artist,title",
                filepath,
            ],
            capture_output=True, text=True, timeout=15,
        )
        data = json.loads(result.stdout)
        artist, album, title = "", "", ""

        fmt_tags = data.get("format", {}).get("tags", {})
        artist = fmt_tags.get("album_artist") or fmt_tags.get("artist", "")
        album = fmt_tags.get("album", "")
        title = fmt_tags.get("title", "")

        if (not artist or not title) and "streams" in data:
            for stream in data["streams"]:
                stags = stream.get("tags", {})
                if not artist:
                    artist = stags.get("album_artist") or stags.get("artist", "")
                if not title:
                    title = stags.get("title", "")
                if not album:
                    album = stags.get("album", "")
                if artist and title:
                    break

        return {
            "artist": artist.strip(),
            "album": album.strip(),
            "title": title.strip(),
        }
    except Exception:
        return {"artist": "", "album": "", "title": ""}


def clean_title(title):
    title = DIRTY_TITLE_RE.sub("", title)
    title = YEAR_RE.sub("", title)
    return title.strip()


def fetch_lrc(artist, title, album=""):
    params = {
        "artist_name": artist,
        "track_name": title,
    }
    if album:
        params["album_name"] = album

    url = f"{LRCLIB_API}/get?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())
        synced = data.get("syncedLyrics")
        if synced and len(synced) > 20:
            return synced.strip()
    except urllib.error.HTTPError:
        pass
    except Exception:
        pass
    return None


def search_lrc(artist, title, album=""):
    params = {
        "artist_name": artist,
        "track_name": title,
    }
    if album:
        params["album_name"] = album

    url = f"{LRCLIB_API}/search?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            results = json.loads(resp.read())
        for r in results[:5]:
            synced = r.get("syncedLyrics")
            if synced and len(synced) > 20:
                return synced.strip()
    except Exception:
        pass
    return None


def file_has_lrc(audio_path):
    lrc_path = audio_path.with_suffix(".lrc")
    return lrc_path.exists() and lrc_path.stat().st_size > 0


def save_lrc(audio_path, lrc_text):
    lrc_path = audio_path.with_suffix(".lrc")
    with open(lrc_path, "w", encoding="utf-8") as f:
        f.write(lrc_text + "\n")
    os.chmod(lrc_path, 0o664)


def process_file(audio_path):
    if file_has_lrc(audio_path):
        return "skip"

    tags = get_tags(audio_path)
    artist = tags["artist"]
    title = tags["title"]
    album = tags["album"]

    if not artist or not title:
        return "no_tags"

    log(f"  {artist} - {title}")
    time.sleep(REQUEST_DELAY)

    lrc = fetch_lrc(artist, title, album)
    if lrc:
        save_lrc(audio_path, lrc)
        return "success"

    clean_t = clean_title(title)
    if clean_t and clean_t != title:
        time.sleep(REQUEST_DELAY)
        lrc = fetch_lrc(artist, clean_t, album)
        if lrc:
            save_lrc(audio_path, lrc)
            return "success"

    time.sleep(REQUEST_DELAY)
    lrc = search_lrc(artist, title, album)
    if lrc:
        save_lrc(audio_path, lrc)
        return "success"

    return "not_found"


def main():
    music_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/media/music/library")
    if not music_dir.exists():
        log(f"Music directory does not exist: {music_dir}")
        sys.exit(1)

    log(f"Scanning {music_dir} ...")

    files = []
    for dirpath, _, filenames in os.walk(music_dir):
        for f in filenames:
            if Path(f).suffix.lower() in AUDIO_EXTS:
                files.append(Path(dirpath) / f)

    total = len(files)
    log(f"Found {total} audio files")

    stats = {"skip": 0, "success": 0, "no_tags": 0, "not_found": 0}

    for fp in files:
        result = process_file(fp)
        stats[result] = stats.get(result, 0) + 1

    log(f"Done. {json.dumps(stats)}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Elisheva Cover Daemon — fetches album cover art from MusicBrainz/Cover Art Archive."""

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

MB_API = "https://musicbrainz.org/ws/2"
USER_AGENT = "ElishevaCoverDaemon/2.0"
REQUEST_DELAY = 1.1

AUDIO_EXTS = {".flac", ".opus"}
COVER_NAMES = {"cover.jpg", "cover.png", "folder.jpg", "folder.png", "front.jpg", "front.png"}
YEAR_SUFFIX_RE = re.compile(r"\s*[\(\[\-\.]\s*\d{4}\s*[\)\]\.]?\s*$")
YEAR_PREFIX_RE = re.compile(r"^\d{4}\s*[\-\.]\s*")


def log(msg):
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}", flush=True)


def label(artist, album):
    return f"{artist} - {album}" if artist else album


def has_cover(album_dir):
    return any((album_dir / name).exists() for name in COVER_NAMES)


def get_audio_files(album_dir):
    files = []
    try:
        with os.scandir(album_dir) as it:
            for entry in it:
                if entry.is_file() and Path(entry.name).suffix.lower() in AUDIO_EXTS:
                    files.append(entry.path)
    except PermissionError:
        pass
    return sorted(files)


def get_tags(filepath):
    try:
        result = subprocess.run(
            [
                "ffprobe", "-v", "quiet", "-print_format", "json",
                "-show_entries",
                "format_tags=artist,album,album_artist:stream_tags=artist,album,album_artist",
                filepath,
            ],
            capture_output=True, text=True, timeout=15,
        )
        data = json.loads(result.stdout)
        artist, album = "", ""

        fmt_tags = data.get("format", {}).get("tags", {})
        artist = fmt_tags.get("album_artist") or fmt_tags.get("artist", "")
        album = fmt_tags.get("album", "")

        if (not artist or not album) and "streams" in data:
            for stream in data["streams"]:
                stags = stream.get("tags", {})
                if not artist:
                    artist = stags.get("album_artist") or stags.get("artist", "")
                if not album:
                    album = stags.get("album", "")
                if artist and album:
                    break

        return {"artist": artist.strip(), "album": album.strip()}
    except Exception:
        return {"artist": "", "album": ""}


def clean_name(name):
    return YEAR_SUFFIX_RE.sub("", name).strip()


def strip_year_prefix(name):
    m = YEAR_PREFIX_RE.match(name)
    return name[m.end():].strip() if m else name


def identify_from_folder(folder_name):
    for sep in [" - ", " \u2013 ", " \u2014 "]:
        if sep in folder_name:
            parts = folder_name.split(sep)

            if len(parts) >= 3 and re.match(r"^\d{4}$", parts[0].strip()):
                artist = parts[1].strip()
                album = clean_name(sep.join(parts[2:]).strip())
                return artist, album

            artist = parts[0].strip()
            album = clean_name(sep.join(parts[1:]).strip())
            return strip_year_prefix(artist), album

    return "", clean_name(folder_name)


def search_mb(artist, album):
    if artist and album:
        query = "artist:{0} AND release:{1}".format(artist, album)
    else:
        query = "release:{0}".format(album)
    url = f"{MB_API}/release/?query={urllib.parse.quote(query)}&fmt=json&limit=5"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = json.loads(resp.read())
        releases = data.get("releases", [])
        if not releases:
            return None
        target = album.lower().replace("-", " ")
        for rel in releases:
            if rel.get("title", "").lower().replace("-", " ") == target:
                return rel["id"]
        return releases[0]["id"]
    except Exception:
        return None


def search_with_retries(artist, album):
    mbid = search_mb(artist, album)
    if mbid:
        return mbid

    clean = YEAR_SUFFIX_RE.sub("", album).strip()
    if clean and clean != album:
        time.sleep(REQUEST_DELAY)
        mbid = search_mb(artist, clean)
        if mbid:
            return mbid

    if artist and album:
        time.sleep(REQUEST_DELAY)
        mbid = search_mb(album, artist)
        if mbid:
            return mbid

    time.sleep(REQUEST_DELAY)
    mbid = search_mb("", album or clean)
    if mbid:
        return mbid

    return None


def download_cover(mbid, output_path):
    for suffix in ("/front", "/front-500", "/front-250", ""):
        url = f"https://coverartarchive.org/release/{mbid}{suffix}"
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = resp.read()
                if len(data) > 1024:
                    with open(output_path, "wb") as f:
                        f.write(data)
                    os.chmod(output_path, 0o664)
                    return True
        except urllib.error.HTTPError:
            continue
        except Exception:
            continue
    return False


def extract_embedded_cover(filepath, output_path):
    ext = Path(filepath).suffix.lower()
    try:
        if ext == ".flac":
            result = subprocess.run(
                ["metaflac", "--export-picture-to", output_path, filepath],
                capture_output=True, timeout=30,
            )
            if result.returncode == 0 and Path(output_path).exists():
                if Path(output_path).stat().st_size > 1024:
                    return True

        result = subprocess.run(
            [
                "ffmpeg", "-y", "-i", filepath, "-map", "0:v:0",
                "-c:v", "copy", "-f", "image2", output_path,
            ],
            capture_output=True, timeout=30,
        )
        if Path(output_path).exists() and Path(output_path).stat().st_size > 1024:
            return True

        result = subprocess.run(
            ["ffmpeg", "-y", "-i", filepath, "-an", "-vcodec", "copy", output_path],
            capture_output=True, timeout=30,
        )
        if Path(output_path).exists() and Path(output_path).stat().st_size > 1024:
            return True
    except Exception:
        pass
    return False


def process_album(album_dir):
    dir_name = album_dir.name
    if has_cover(album_dir):
        return "skip"

    audio_files = get_audio_files(album_dir)
    if not audio_files:
        return "no_audio"

    artist, album = "", ""

    tags = get_tags(audio_files[0])
    if tags["artist"] and tags["album"]:
        artist, album = tags["artist"], clean_name(tags["album"])

    if not artist or not album:
        folder_artist, folder_album = identify_from_folder(dir_name)
        if folder_artist and folder_album:
            artist, album = folder_artist, folder_album

    if not artist or not album:
        parent = album_dir.parent.name
        if parent not in (".", "library", "music", "", "downloads"):
            artist = parent
            album = dir_name

    if not artist or not album:
        album = clean_name(dir_name) or dir_name
        artist = ""

    if not album:
        log(f"  Cannot identify: {album_dir}")
        return "no_tags"

    lbl = label(artist, album)
    log(f"  Searching: {lbl}")
    time.sleep(REQUEST_DELAY)

    mbid = search_with_retries(artist, album)
    if mbid:
        time.sleep(REQUEST_DELAY)
        cover_path = album_dir / "cover.jpg"
        if download_cover(mbid, cover_path):
            log(f"  OK: {lbl}")
            return "success"
        log(f"  No cover on CAA: {lbl}")
        return "no_cover"

    log(f"  Not on MB: {lbl}")

    log("  Fallback: extracting embedded cover...")
    cover_path = album_dir / "cover.jpg"
    for f in audio_files[:5]:
        if extract_embedded_cover(f, cover_path):
            log(f"  OK (embedded): {lbl}")
            return "success_embedded"

    log(f"  No cover at all: {lbl}")
    return "not_found"


def walk_music(music_dir):
    album_dirs = []
    for dirpath, dirnames, filenames in os.walk(music_dir):
        dirpath = Path(dirpath)
        if any(Path(f).suffix.lower() in AUDIO_EXTS for f in filenames):
            album_dirs.append(dirpath)
            dirnames.clear()
    return album_dirs


def main():
    music_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/media/music/library")
    if not music_dir.exists():
        log(f"Music directory does not exist: {music_dir}")
        sys.exit(1)

    log(f"Scanning {music_dir} ...")
    album_dirs = walk_music(music_dir)
    total = len(album_dirs)
    log(f"Found {total} album directories")

    stats = {
        "skip": 0, "success": 0, "success_embedded": 0,
        "no_audio": 0, "no_tags": 0, "not_found": 0, "no_cover": 0,
    }

    for d in album_dirs:
        result = process_album(d)
        stats[result] = stats.get(result, 0) + 1

    log(f"Done. {json.dumps(stats)}")


if __name__ == "__main__":
    main()

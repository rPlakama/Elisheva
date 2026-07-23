#!/usr/bin/env python3
"""Elisheva General Music Maintainer — unified FLAC→Opus transcoding, stale FLAC
cleanup, cover art fetching, lyrics fetching, and NFO generation."""

import json
import os
import re
import shutil
import subprocess
import sys
import textwrap
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from multiprocessing import Pool, cpu_count
from pathlib import Path

# ── Configuration ────────────────────────────────────────────────────────────

MB_API = "https://musicbrainz.org/ws/2"
LRCLIB_API = "https://lrclib.net/api"
USER_AGENT = "ElishevaMusicMaintainer/3.0 (https://github.com/elisheva)"
REQUEST_DELAY = 1.1
LRCLIB_DELAY = 0.6

AUDIO_EXTS = {".flac", ".opus"}
COVER_NAMES = {"cover.jpg", "cover.png", "folder.jpg", "folder.png",
               "front.jpg", "front.png"}
YEAR_SUFFIX_RE = re.compile(r"\s*[\(\[\-\.]\s*\d{4}\s*[\)\]\.]?\s*$")
YEAR_PREFIX_RE = re.compile(r"^\d{4}\s*[\-\.]\s*")
DIRTY_TITLE_RE = re.compile(
    r"\s*[\(\[].*?(?:feat\.?|ft\.?|featuring|bonus track|remaster(?:ed)?|"
    r"live|demo|acoustic|instrumental|radio edit|extended|deluxe|"
    r"anniversary|explicit|clean|version).*?[\)\]]\s*",
    re.IGNORECASE,
)

# ── Logging ──────────────────────────────────────────────────────────────────

def log(msg):
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}", flush=True)

def label(artist, album):
    return f"{artist} — {album}" if artist else album

# ── Tag Reading ──────────────────────────────────────────────────────────────

def get_tags(filepath):
    """Read artist/album/title/date tags via ffprobe."""
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "quiet", "-print_format", "json",
             "-show_entries",
             "format_tags=artist,album,album_artist,title,date,genre:"
             "stream_tags=artist,album,album_artist,title,date,genre",
             filepath],
            capture_output=True, text=True, timeout=15,
            stdin=subprocess.DEVNULL,
        )
        data = json.loads(result.stdout)
        tags = {"artist": "", "album_artist": "", "album": "",
                "title": "", "date": "", "genre": ""}

        fmt_tags = data.get("format", {}).get("tags", {})
        tags["album_artist"] = fmt_tags.get("album_artist", "")
        tags["artist"] = fmt_tags.get("artist", "")
        tags["album"] = fmt_tags.get("album", "")
        tags["title"] = fmt_tags.get("title", "")
        tags["date"] = fmt_tags.get("date", "")
        tags["genre"] = fmt_tags.get("genre", "")

        if "streams" in data:
            for stream in data["streams"]:
                stags = stream.get("tags", {})
                for k in tags:
                    if not tags[k]:
                        tags[k] = stags.get(k, "")

        return {k: v.strip() for k, v in tags.items()}
    except Exception:
        return {"artist": "", "album_artist": "", "album": "",
                "title": "", "date": "", "genre": ""}

# ── Helpers ──────────────────────────────────────────────────────────────────

def clean_name(name):
    return YEAR_SUFFIX_RE.sub("", name).strip()

def strip_year_prefix(name):
    m = YEAR_PREFIX_RE.match(name)
    return name[m.end():].strip() if m else name

def clean_title(title):
    title = DIRTY_TITLE_RE.sub("", title)
    title = YEAR_SUFFIX_RE.sub("", title)
    return title.strip()

def has_cover(album_dir):
    return any((album_dir / name).exists() for name in COVER_NAMES)

def get_audio_files(album_dir):
    files = []
    try:
        with os.scandir(album_dir) as it:
            for entry in it:
                if entry.is_file() and Path(entry.name).suffix.lower() in AUDIO_EXTS:
                    files.append(Path(entry.path))
    except PermissionError:
        pass
    return sorted(files)

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

def mb_request(url):
    """Make a MusicBrainz API request with proper user-agent."""
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            return json.loads(resp.read())
    except Exception:
        return None

def walk_album_dirs(music_dir):
    album_dirs = []
    for dirpath, dirnames, filenames in os.walk(music_dir):
        dirpath = Path(dirpath)
        if any(Path(f).suffix.lower() in AUDIO_EXTS for f in filenames):
            album_dirs.append(dirpath)
            dirnames.clear()
    return album_dirs

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
             "-c:a", "libopus", "-b:a", "510k", "-vbr", "on",
             "-compression_level", "10", "-application", "audio",
             str(opus_path)],
            capture_output=True, timeout=600, stdin=subprocess.DEVNULL,
        )
        if result.returncode != 0:
            opus_path.unlink(missing_ok=True)
            return (flac_path_str, "error")
        os.chmod(opus_path, 0o664)
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
# PHASE 3: Cover Art Fetching (enhanced precision)
# ═══════════════════════════════════════════════════════════════════════════════

def search_mb_release(artist, album):
    """Search MusicBrainz for a release, using release-group for precision."""
    if artist and album:
        query = f"artist:{artist} AND release:{album}"
    else:
        query = f"release:{album}"
    url = (f"{MB_API}/release/?query={urllib.parse.quote(query)}"
           f"&fmt=json&limit=10")
    data = mb_request(url)
    if not data:
        return None, None

    releases = data.get("releases", [])
    if not releases:
        return None, None

    target = album.lower().replace("-", " ").strip()

    # Prefer exact title match with highest score
    for rel in releases:
        title = rel.get("title", "").lower().replace("-", " ").strip()
        if title == target:
            rgid = (rel.get("release-group", {}) or {}).get("id")
            return rel["id"], rgid

    # Fallback to first result
    rgid = (releases[0].get("release-group", {}) or {}).get("id")
    return releases[0]["id"], rgid


def download_cover(mbid, rgid, output_path):
    """Try CAA release, then release-group, then generic endpoints."""
    endpoints = []
    # Release-specific covers first (most precise)
    if mbid:
        endpoints.append(f"https://coverartarchive.org/release/{mbid}/front")
    # Release-group covers (catches compilations / reissues)
    if rgid:
        endpoints.append(f"https://coverartarchive.org/release-group/{rgid}/front")
    # Fallback: release root listing
    if mbid:
        endpoints.append(f"https://coverartarchive.org/release/{mbid}")

    for url in endpoints:
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                raw = resp.read()
                if len(raw) > 1024:
                    with open(output_path, "wb") as f:
                        f.write(raw)
                    os.chmod(output_path, 0o664)
                    return True
        except Exception:
            continue
    return False


def extract_embedded_cover(filepath, output_path):
    ext = Path(filepath).suffix.lower()
    try:
        if ext == ".flac":
            result = subprocess.run(
                ["metaflac", "--export-picture-to", str(output_path), str(filepath)],
                capture_output=True, timeout=30, stdin=subprocess.DEVNULL,
            )
            if result.returncode == 0 and Path(output_path).exists():
                if Path(output_path).stat().st_size > 1024:
                    return True
        result = subprocess.run(
            ["ffmpeg", "-y", "-i", str(filepath), "-map", "0:v:0",
             "-c:v", "copy", "-f", "image2", str(output_path)],
            capture_output=True, timeout=30, stdin=subprocess.DEVNULL,
        )
        if Path(output_path).exists() and Path(output_path).stat().st_size > 1024:
            return True
    except Exception:
        pass
    return False


def process_album_cover(album_dir, music_dir):
    if has_cover(album_dir):
        return "skip"
    audio_files = get_audio_files(album_dir)
    if not audio_files:
        return "no_audio"

    artist, album = "", ""
    tags = get_tags(str(audio_files[0]))
    artist = tags.get("album_artist") or tags.get("artist", "")
    album = tags.get("album", "")
    if album:
        album = clean_name(album)

    if not artist or not album:
        folder_artist, folder_album = identify_from_folder(album_dir.name)
        if folder_artist and folder_album:
            artist, album = folder_artist, folder_album

    if not artist or not album:
        parent = album_dir.parent.name
        if parent not in (".", "library", "music", "", "downloads"):
            artist = artist or parent
            album = album or album_dir.name

    if not album:
        album = clean_name(album_dir.name) or album_dir.name

    if not album:
        return "no_tags"

    lbl = label(artist, album)
    log(f"  Cover: {lbl}")
    time.sleep(REQUEST_DELAY)

    # Search with retries
    mbid, rgid = search_mb_release(artist, album)
    if not mbid:
        clean = clean_name(album)
        if clean and clean != album:
            time.sleep(REQUEST_DELAY)
            mbid, rgid = search_mb_release(artist, clean)
    if not mbid and artist:
        time.sleep(REQUEST_DELAY)
        mbid, rgid = search_mb_release("", album)

    if mbid:
        time.sleep(REQUEST_DELAY)
        cover_path = album_dir / "cover.jpg"
        if download_cover(mbid, rgid, str(cover_path)):
            log(f"  ✓ Cover: {lbl}")
            return "success"
        log(f"  No cover on CAA: {lbl}")

    # Fallback: extract embedded
    cover_path = album_dir / "cover.jpg"
    for f in audio_files[:5]:
        if extract_embedded_cover(str(f), str(cover_path)):
            log(f"  ✓ Cover (embedded): {lbl}")
            return "success_embedded"

    log(f"  ✗ No cover: {lbl}")
    return "not_found"


def run_cover_fetch(music_dir):
    log("═══ Phase 3: Cover Art Fetching ═══")
    album_dirs = walk_album_dirs(music_dir)
    log(f"  Found {len(album_dirs)} album directories")
    stats = {"skip": 0, "success": 0, "success_embedded": 0,
             "no_audio": 0, "no_tags": 0, "not_found": 0}
    for d in album_dirs:
        result = process_album_cover(d, music_dir)
        stats[result] = stats.get(result, 0) + 1
    log(f"  Cover fetch done: {json.dumps(stats)}")

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4: NFO Generation (album.nfo + artist.nfo)
# ═══════════════════════════════════════════════════════════════════════════════

def generate_album_nfo(album_dir, music_dir):
    """Create album.nfo with metadata from audio tags + MusicBrainz."""
    nfo_path = album_dir / "album.nfo"
    if nfo_path.exists():
        return False

    audio_files = get_audio_files(album_dir)
    if not audio_files:
        return False

    tags = get_tags(str(audio_files[0]))
    artist = tags.get("album_artist") or tags.get("artist", "")
    album = tags.get("album", "")
    date = tags.get("date", "")
    genre = tags.get("genre", "")

    if not artist:
        folder_artist, _ = identify_from_folder(album_dir.name)
        artist = folder_artist or album_dir.parent.name
    if not album:
        _, folder_album = identify_from_folder(album_dir.name)
        album = folder_album or album_dir.name

    # Extract year from date
    year = ""
    if date:
        m = re.match(r"(\d{4})", date)
        if m:
            year = m.group(1)

    track_count = len(audio_files)

    content = textwrap.dedent(f"""\
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <album>
          <title>{_xml_escape(album)}</title>
          <artistdesc>{_xml_escape(artist)}</artistdesc>
          <year>{year}</year>
          <genre>{_xml_escape(genre)}</genre>
          <tracks>{track_count}</tracks>
        </album>
    """)

    with open(nfo_path, "w", encoding="utf-8") as f:
        f.write(content)
    os.chmod(nfo_path, 0o664)
    return True


def generate_artist_nfo(artist_dir):
    """Create artist.nfo in an artist-level directory if missing."""
    nfo_path = artist_dir / "artist.nfo"
    if nfo_path.exists():
        return False

    artist_name = artist_dir.name

    # Try to get a better name from a child album's tags
    for child in sorted(artist_dir.iterdir()):
        if child.is_dir():
            audio = get_audio_files(child)
            if audio:
                tags = get_tags(str(audio[0]))
                tagged_artist = tags.get("album_artist") or tags.get("artist", "")
                if tagged_artist:
                    artist_name = tagged_artist
                break

    content = textwrap.dedent(f"""\
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <artist>
          <name>{_xml_escape(artist_name)}</name>
        </artist>
    """)

    with open(nfo_path, "w", encoding="utf-8") as f:
        f.write(content)
    os.chmod(nfo_path, 0o664)
    return True


def _xml_escape(text):
    return (text.replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace('"', "&quot;")
            .replace("'", "&apos;"))


def run_nfo_generation(music_dir):
    log("═══ Phase 4: NFO Generation ═══")
    album_dirs = walk_album_dirs(music_dir)
    artist_dirs = set()
    album_nfos = 0
    artist_nfos = 0

    for d in album_dirs:
        if generate_album_nfo(d, music_dir):
            log(f"  ✓ album.nfo: {d.relative_to(music_dir)}")
            album_nfos += 1
        # Collect artist-level dirs (parent of album dirs, but not the root)
        parent = d.parent
        if parent != music_dir and parent not in artist_dirs:
            artist_dirs.add(parent)

    for ad in sorted(artist_dirs):
        if generate_artist_nfo(ad):
            log(f"  ✓ artist.nfo: {ad.relative_to(music_dir)}")
            artist_nfos += 1

    log(f"  NFO done: {album_nfos} album.nfo, {artist_nfos} artist.nfo created")

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 5: Lyrics Fetching (carried over from lyrics-daemon)
# ═══════════════════════════════════════════════════════════════════════════════

def fetch_lrc(artist, title, album=""):
    params = {"artist_name": artist, "track_name": title}
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
    except Exception:
        pass
    return None


def search_lrc(artist, title, album=""):
    params = {"artist_name": artist, "track_name": title}
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


def process_lyrics(audio_path):
    lrc_path = audio_path.with_suffix(".lrc")
    if lrc_path.exists() and lrc_path.stat().st_size > 0:
        return "skip"

    tags = get_tags(str(audio_path))
    artist = tags.get("album_artist") or tags.get("artist", "")
    title = tags.get("title", "")
    album = tags.get("album", "")

    if not artist or not title:
        return "no_tags"

    log(f"  Lyrics: {artist} — {title}")
    time.sleep(LRCLIB_DELAY)

    lrc = fetch_lrc(artist, title, album)
    if lrc:
        _save_lrc(lrc_path, lrc)
        return "success"

    clean_t = clean_title(title)
    if clean_t and clean_t != title:
        time.sleep(LRCLIB_DELAY)
        lrc = fetch_lrc(artist, clean_t, album)
        if lrc:
            _save_lrc(lrc_path, lrc)
            return "success"

    time.sleep(LRCLIB_DELAY)
    lrc = search_lrc(artist, title, album)
    if lrc:
        _save_lrc(lrc_path, lrc)
        return "success"

    return "not_found"


def _save_lrc(lrc_path, text):
    with open(lrc_path, "w", encoding="utf-8") as f:
        f.write(text + "\n")
    os.chmod(lrc_path, 0o664)


def run_lyrics_fetch(music_dir):
    log("═══ Phase 5: Lyrics Fetching ═══")
    files = []
    for dirpath, _, filenames in os.walk(music_dir):
        for f in filenames:
            if Path(f).suffix.lower() in AUDIO_EXTS:
                files.append(Path(dirpath) / f)

    log(f"  Found {len(files)} audio files")
    stats = {"skip": 0, "success": 0, "no_tags": 0, "not_found": 0}
    for fp in files:
        result = process_lyrics(fp)
        stats[result] = stats.get(result, 0) + 1
    log(f"  Lyrics done: {json.dumps(stats)}")

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    music_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/media/music/library")
    if not music_dir.exists():
        log(f"Music directory does not exist: {music_dir}")
        sys.exit(1)

    log(f"General Music Maintainer starting — {music_dir}")

    run_transcode(music_dir)
    run_flac_cleanup(music_dir)
    run_cover_fetch(music_dir)
    run_nfo_generation(music_dir)
    run_lyrics_fetch(music_dir)

    log("All phases complete.")


if __name__ == "__main__":
    main()

#!/bin/bash
# worth-it: turn a social-media video link into something Claude can judge.
#   ingest.sh <url> [out-dir]
#   ingest.sh --setup          install the tools only (the cloud environment's setup script runs this)
# Writes into out-dir (default: a new temp folder, printed at the end):
#   info.txt        title, author, date, caption, length, views (from the post)
#   transcript.txt  what is said, word for word (whisper.cpp, local, Hebrew and English)
#   frames/NN.jpg   one frame every few seconds, at most 16 (what is shown on screen)
# Nothing leaves the computer except the download itself. The video and audio are deleted at the end.
set -uo pipefail

URL="${1:?usage: ingest.sh <url> [out-dir] | ingest.sh --setup}"
OUT="${2:-$(mktemp -d "${TMPDIR:-/tmp}/worth-it.XXXXXX")}"
HERE="$(cd "$(dirname "$0")" && pwd)"
# The speech model lives outside the skill folder, so plugin updates don't delete it (an old copy next to the script still works).
MODEL="$HERE/models/ggml-large-v3-turbo-q5_0.bin"
[ -f "$MODEL" ] || MODEL="${XDG_CACHE_HOME:-$HOME/.cache}/worth-it/ggml-large-v3-turbo-q5_0.bin"
MAX_FRAMES=16

# First run: install what's missing (Homebrew on a Mac, pip/apt/a source build on Linux).
setup() {
  export PATH="$HOME/.local/bin:$PATH"
  if [ "$(uname)" = Darwin ] && command -v brew >/dev/null; then
    for p in yt-dlp ffmpeg whisper-cpp; do
      t=$p; [ $p = whisper-cpp ] && t=whisper-cli
      command -v $t >/dev/null || { echo "Installing $p with Homebrew (first run only)..." >&2; brew install -q $p >&2; }
    done
  fi
  command -v yt-dlp >/dev/null || python3 -m pip install -q --user -U yt-dlp >&2 \
    || python3 -m pip install -q --user --break-system-packages -U yt-dlp >&2
  if ! command -v ffmpeg >/dev/null; then
    { sudo -n apt-get -qq update && sudo -n apt-get -qq install -y ffmpeg; } >/dev/null 2>&1 \
      || { apt-get -qq update && apt-get -qq install -y ffmpeg; } >/dev/null 2>&1
  fi
  if ! command -v whisper-cli >/dev/null; then
    local src="$HOME/.cache/whisper.cpp"
    if [ ! -x "$src/build/bin/whisper-cli" ]; then
      echo "Building whisper.cpp (first run only, about 2 minutes)..." >&2
      git clone -q --depth 1 --branch v1.9.5 https://github.com/ggml-org/whisper.cpp "$src" 2>/dev/null
      (cd "$src" && cmake -B build -DCMAKE_BUILD_TYPE=Release >/dev/null && cmake --build build -j --target whisper-cli >/dev/null)
    fi
    export PATH="$src/build/bin:$PATH"
  fi
  for t in yt-dlp ffmpeg whisper-cli; do command -v "$t" >/dev/null || echo "SETUP_FAILED: $t not installed" >&2; done
  if [ ! -f "$MODEL" ]; then
    echo "Downloading the speech model (first run only, about 550 MB)..." >&2
    mkdir -p "$(dirname "$MODEL")"
    curl -fsSL -o "$MODEL.part" https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin \
      && [ "$( (sha256sum "$MODEL.part" 2>/dev/null || shasum -a 256 "$MODEL.part") | cut -d' ' -f1)" = 394221709cd5ad1f40c46e6031ca61bce88931e6e088c188294c6d5a55ffa7e2 ] \
      && mv "$MODEL.part" "$MODEL" \
      || { rm -f "$MODEL.part"; echo "SETUP_FAILED: speech model download (huggingface.co); no transcript" >&2; }
  fi
}
setup
[ "$URL" = --setup ] && { echo "SETUP_DONE"; exit 0; }

# Only real web links: nothing that yt-dlp could read as an option.
case "$URL" in
  http://*|https://*) ;;
  *) echo "NOT_A_LINK: expected an http(s) link"; exit 3 ;;
esac
HOST="${URL#*://}"; HOST="${HOST%%/*}"; HOST="${HOST%%\?*}"; HOST="${HOST##*@}"; HOST="${HOST%%:*}"; HOST="$(printf %s "$HOST" | tr A-Z a-z)"
# Browser cookies are offered only to these sites, never to an unknown link.
social_host() {
  case "$HOST" in
    instagram.com|*.instagram.com|tiktok.com|*.tiktok.com|youtube.com|*.youtube.com|youtu.be|x.com|*.x.com|twitter.com|*.twitter.com|linkedin.com|*.linkedin.com|facebook.com|*.facebook.com|fb.watch) return 0 ;;
  esac
  return 1
}

mkdir -p "$OUT/frames"
cd "$OUT" || exit 1

fetch() { yt-dlp --no-playlist --no-warnings -q -f "b[height<=720]/bv*[height<=720]+ba/b" \
  --write-info-json -o "video.%(ext)s" "$@" -- "$URL"; }

# Public posts first; if the site wants a sign-in, use the browser's cookies (read locally, never sent elsewhere).
# (Only on the Mac: a cloud machine has no browser.)
if ! fetch 2>err.txt && [ "$(uname)" = Darwin ] && social_host; then
  for browser in chrome safari arc brave firefox; do
    fetch --cookies-from-browser "$browser" 2>>err.txt && break
  done
fi

VIDEO="$(ls video.* 2>/dev/null | grep -v '\.json$' | head -1)"
if [ -n "$(ls *.info.json 2>/dev/null)" ]; then
  python3 -I - <<'EOF' > info.txt
import json,glob,datetime
d=json.load(open(glob.glob("*.info.json")[0]))
date=d.get("upload_date") or ""
if len(date)==8: date=f"{date[6:]}.{date[4:6]}.{date[:4]}"
for k,v in [("Title",d.get("title")),("Author",d.get("uploader") or d.get("channel")),("Date",date),
            ("Length (s)",d.get("duration")),("Views",d.get("view_count")),("Likes",d.get("like_count")),
            ("Link",d.get("webpage_url")),("Caption",d.get("description"))]:
    if v not in (None,""): print(f"{k}: {v}")
EOF
  rm -f *.info.json
fi

if [ -z "$VIDEO" ]; then
  echo "NO_VIDEO: couldn't download it. Errors:"; grep -i error err.txt | head -5
  echo "OUT=$OUT"
  exit 2
fi
rm -f err.txt

# Audio → transcript (language detected automatically).
ffmpeg -loglevel error -y -i "$VIDEO" -vn -ac 1 -ar 16000 audio.wav
if [ -s audio.wav ] && [ -f "$MODEL" ]; then
  whisper-cli -m "$MODEL" -l auto -nt -np -f audio.wav > transcript.txt 2>/dev/null
  sed -e 's/^[[:space:]]*//' -e '/^$/d' transcript.txt > t.tmp && mv t.tmp transcript.txt  # no sed -i: it differs on Mac and Linux
fi
[ -s transcript.txt ] || echo "(no speech)" > transcript.txt

# Frames: evenly spread across the video, at most MAX_FRAMES.
DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO" | cut -d. -f1)"
DUR="${DUR:-30}"; [ "$DUR" -lt 1 ] && DUR=1
EVERY=$(( (DUR + MAX_FRAMES - 1) / MAX_FRAMES )); [ "$EVERY" -lt 2 ] && EVERY=2
ffmpeg -loglevel error -y -i "$VIDEO" -vf "fps=1/$EVERY,scale=540:-2" -frames:v "$MAX_FRAMES" -q:v 5 frames/%02d.jpg

rm -f "$VIDEO" audio.wav
echo "OK: $(ls frames | wc -l | tr -d ' ') frames, $(wc -w < transcript.txt | tr -d ' ') words, ${DUR}s"
echo "OUT=$OUT"

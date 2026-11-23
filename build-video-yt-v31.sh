#!/bin/bash
# Build post-TikTok video v3.1 from YouTube footage:
# The World's Hardest Game 0-death speedrun (Snubby Land, 2009).
# v3.1 fixes the user complaint (23 Nov 21:45 WIB): "kok videonya g ada day
# one and day seven? trus seperti kyk ada yg disingkat".
# Root cause found: in v3 the DAY ONE / DAY SEVEN overlays FADED OUT after
# 3.0s (FADE alpha expression), so most of each clip showed plain gameplay
# with no label, and days 2-6 were skipped entirely (jump straight from
# level 1/30 to level 30/30).
# v3.1 changes:
#  - NEW title card (2s): "DAY ONE vs DAY SEVEN" in one frame
#  - DAY ONE / DAY SEVEN labels PERSISTENT for the whole clip (fade-in only,
#    no fade-out)
#  - NEW montage (5x1s): DAY 2..DAY 6 flashes from mid levels
#    (6/30, 11/30, 17/30, 21/30, 26/30) so the week is not skipped
#  - segB (ONE WEEK LATER) + segD (referral end card) kept from v2
# Layout: blurred-background 9:16 (source is 480x360), gameplay centered.
# Timeline (28s): segT 2s | segA day1 7s | m2-m6 5s | segB 1.5s |
#                 segC7 day7 7s | segC 3s | segD 2.5s
# Final: video/day-one-day-seven.mp4 (1080x1920, 30fps, silent AAC)
set -euo pipefail
cd "$(dirname "$0")"

FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
[ -f "$FONT" ] || { echo "no DejaVu font found"; exit 1; }

SRC="yt/worlds-hardest-speedrun.mp4"
# 480x360 -> blurred 1080x1920 bg + centered 1080x810 gameplay
BG="split[a][b];[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=40[bg];[b]scale=1080:810:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,format=yuv420p,fps=30"

# Persistent label: fade in 0.4s, then STAYS (v3 faded out at 3.0s).
HOLD="alpha='if(lt(t,0.4),t/0.4,1)'"
MAIN="fontfile=$FONT:fontcolor=white:borderw=10:bordercolor=black:x=(w-text_w)/2:y=300:fontsize=150:$HOLD"
SUB="fontfile=$FONT:fontcolor=white:borderw=6:bordercolor=black:x=(w-text_w)/2:y=490:fontsize=56:$HOLD"

echo "== segT (title card 2s: DAY ONE vs DAY SEVEN)"
ffmpeg -y -v error -f lavfi -i color=c=0x111111:s=1080x1920:r=30:d=2 \
  -vf "drawtext=fontfile=$FONT:fontcolor=white:borderw=8:bordercolor=black:x=(w-text_w)/2:y=700:fontsize=150:text='DAY ONE',drawtext=fontfile=$FONT:fontcolor=#ffd23f:borderw=6:bordercolor=black:x=(w-text_w)/2:y=900:fontsize=80:text='VS',drawtext=fontfile=$FONT:fontcolor=white:borderw=8:bordercolor=black:x=(w-text_w)/2:y=1030:fontsize=150:text='DAY SEVEN'" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segT.mp4

echo "== segA-yt (day1: level 1/30, t=5-12, label persistent)"
ffmpeg -y -v error -ss 5 -i "$SRC" -t 7 \
  -filter_complex "$BG,drawtext=$MAIN:text='DAY ONE',drawtext=$SUB:text='SO EASY ★☆☆☆☆'" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segA-yt.mp4

echo "== montage DAY 2..6 (1s each)"
i=2
for spec in "60 DAY 2" "125 DAY 3" "190 DAY 4" "255 DAY 5" "320 DAY 6"; do
  set -- $spec; t=$1; label="$2 $3"
  echo "   m$i: t=$t label='$label'"
  ffmpeg -y -v error -ss "$t" -i "$SRC" -t 1 \
    -filter_complex "$BG,drawtext=$MAIN:text='$label'" \
    -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast "m$i.mp4"
  i=$((i+1))
done

echo "== segC7-yt (day7: level 30/30, t=382-389, label persistent)"
ffmpeg -y -v error -ss 382 -i "$SRC" -t 7 \
  -filter_complex "$BG,drawtext=$MAIN:text='DAY SEVEN',drawtext=$SUB:text='SO HARD ★★★★★'" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segC7-yt.mp4

echo "== segC-yt (day7 last 3s, t=389-392)"
ffmpeg -y -v error -ss 389 -i "$SRC" -t 3 \
  -filter_complex "$BG" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segC-yt.mp4

echo "== concat + silent audio"
ls segT.mp4 segA-yt.mp4 m2.mp4 m3.mp4 m4.mp4 m5.mp4 m6.mp4 segB.mp4 segC7-yt.mp4 segC-yt.mp4 segD.mp4
printf "file 'segT.mp4'\nfile 'segA-yt.mp4'\nfile 'm2.mp4'\nfile 'm3.mp4'\nfile 'm4.mp4'\nfile 'm5.mp4'\nfile 'm6.mp4'\nfile 'segB.mp4'\nfile 'segC7-yt.mp4'\nfile 'segC-yt.mp4'\nfile 'segD.mp4'\n" > concat-yt-v31.txt
ffmpeg -y -v error -f concat -safe 0 -i concat-yt-v31.txt \
  -f lavfi -i anullsrc=r=44100:cl=stereo \
  -map 0:v -map 1:a -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast \
  -c:a aac -b:a 128k -shortest -movflags +faststart \
  video/day-one-day-seven.mp4

echo "== done"
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 video/day-one-day-seven.mp4

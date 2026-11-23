#!/bin/bash
# Build post-TikTok video v3 from YouTube footage:
# The World's Hardest Game 0-death speedrun (Snubby Land, 2009).
# Day 1 = level 1/30 (easy, few dots), Day 7 = level 30/30 (brutal red-dot hell).
# Layout: blurred-background 9:16 (source is 480x360), gameplay centered.
# Segments: segA-yt (day1 7s + DAY ONE / SO EASY)
#           segB (kept: ONE WEEK LATER card)
#           segC7-yt (day7 7s + DAY SEVEN / SO HARD)
#           segC-yt (day7 last 3s, no overlay)
#           segD (kept: referral end card)
# Final: video/day-one-day-seven.mp4 (1080x1920, 30fps, silent AAC)
set -euo pipefail
cd "$(dirname "$0")"

FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
[ -f "$FONT" ] || { echo "no DejaVu font found"; exit 1; }

SRC="yt/worlds-hardest-speedrun.mp4"
# 480x360 -> blurred 1080x1920 bg + centered 1080x810 gameplay
BG="split[a][b];[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=40[bg];[b]scale=1080:810:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,format=yuv420p,fps=30"

# Overlay fades in over 0.4s, holds, fades out 2.2s -> 3.0s. Text in top blurred band.
FADE="alpha='if(lt(t,0.4),t/0.4,if(gt(t,2.2),(3.0-t)/0.8,1))'"
MAIN="fontfile=$FONT:fontcolor=white:borderw=10:bordercolor=black:x=(w-text_w)/2:y=300:fontsize=150:$FADE"
SUB="fontfile=$FONT:fontcolor=white:borderw=6:bordercolor=black:x=(w-text_w)/2:y=490:fontsize=56:$FADE"

echo "== segA-yt (day1: level 1/30, t=5-12)"
ffmpeg -y -v error -ss 5 -i "$SRC" -t 7 \
  -filter_complex "$BG,drawtext=$MAIN:text='DAY ONE',drawtext=$SUB:text='SO EASY ★☆☆☆☆'" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segA-yt.mp4

echo "== segC7-yt (day7: level 30/30, t=382-389)"
ffmpeg -y -v error -ss 382 -i "$SRC" -t 7 \
  -filter_complex "$BG,drawtext=$MAIN:text='DAY SEVEN',drawtext=$SUB:text='SO HARD ★★★★★'" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segC7-yt.mp4

echo "== segC-yt (day7 last 3s, t=389-392)"
ffmpeg -y -v error -ss 389 -i "$SRC" -t 3 \
  -filter_complex "$BG" \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segC-yt.mp4

echo "== concat (segA-yt segB segC7-yt segC-yt segD) + silent audio"
printf "file 'segA-yt.mp4'\nfile 'segB.mp4'\nfile 'segC7-yt.mp4'\nfile 'segC-yt.mp4'\nfile 'segD.mp4'\n" > concat-yt.txt
ffmpeg -y -v error -f concat -safe 0 -i concat-yt.txt \
  -f lavfi -i anullsrc=r=44100:cl=stereo \
  -map 0:v -map 1:a -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast \
  -c:a aac -b:a 128k -shortest -movflags +faststart \
  video/day-one-day-seven.mp4

echo "== done"
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 video/day-one-day-seven.mp4
for f in segA-yt.mp4 segC7-yt.mp4 segC-yt.mp4; do
  echo -n "$f: "; ffprobe -v error -show_entries format=duration -of csv=p=0 "$f"
done

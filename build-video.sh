#!/bin/bash
# Rebuild ORB HOP video v2.0 from freshly filmed frames.
# Segments: segA (day1 0-7s + DAY ONE / SO EASY overlay)
#           segB (kept: ONE WEEK LATER / DAY SEVEN card)
#           segC7 (day7 0-7s + DAY SEVEN / SO HARD overlay)
#           segC (day7 7-10s, no overlay)
#           segD (kept: referral end card)
# Final: video/day-one-day-seven.mp4 (1080x1920, 30fps, silent AAC)
set -euo pipefail
cd "$(dirname "$0")"

FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
[ -f "$FONT" ] || { echo "no DejaVu font found"; exit 1; }

# Overlay fades in over 0.4s, holds, fades out 2.2s -> 3.0s.
FADE="alpha='if(lt(t,0.4),t/0.4,if(gt(t,2.2),(3.0-t)/0.8,1))'"
MAIN="fontfile=$FONT:fontcolor=white:borderw=10:bordercolor=black:x=(w-text_w)/2:y=660:fontsize=150:$FADE"
SUB="fontfile=$FONT:fontcolor=white:borderw=6:bordercolor=black:x=(w-text_w)/2:y=880:fontsize=56:$FADE"

echo "== segA (day1)"
ffmpeg -y -v error -framerate 15 -start_number 0 -i frames/day1-%03d.png \
  -vf "fps=30,drawtext=$MAIN:text='DAY ONE',drawtext=$SUB:text='SO EASY ★☆☆☆☆'" \
  -t 7.0667 -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segA.mp4

echo "== segC7 (day7 first 7s)"
ffmpeg -y -v error -framerate 15 -start_number 0 -i frames/day7-%03d.png \
  -vf "fps=30,drawtext=$MAIN:text='DAY SEVEN',drawtext=$SUB:text='SO HARD ★★★★★'" \
  -t 7.0667 -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segC7.mp4

echo "== segC (day7 last 3s)"
ffmpeg -y -v error -framerate 15 -start_number 105 -i frames/day7-%03d.png \
  -vf "fps=30" \
  -t 3.0667 -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast segC.mp4

echo "== concat (segA segB segC7 segC segD) + silent audio"
ffmpeg -y -v error -f concat -safe 0 -i concat.txt \
  -f lavfi -i anullsrc=r=44100:cl=stereo \
  -map 0:v -map 1:a -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast \
  -c:a aac -b:a 128k -shortest -movflags +faststart \
  video/day-one-day-seven.mp4

echo "== done"
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 video/day-one-day-seven.mp4
for f in segA.mp4 segC7.mp4 segC.mp4; do
  echo -n "$f: "; ffprobe -v error -show_entries format=duration -of csv=p=0 "$f"
done

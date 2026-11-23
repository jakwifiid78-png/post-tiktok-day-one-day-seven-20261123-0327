# ORB HOP — Day one, day seven

[![bounty](https://make.fun/badge/post-tiktok-day-one-day-seven-20261123-0327.svg)](https://make.fun/bounty/post-tiktok-day-one-day-seven-20261123-0327)
[![rank](https://make.fun/badge/post-tiktok-day-one-day-seven-20261123-0327/jakwifiid78-png/post-tiktok-day-one-day-seven-20261123-0327/rank.svg)](https://make.fun/bounty/post-tiktok-day-one-day-seven-20261123-0327)
[![reward](https://make.fun/badge/post-tiktok-day-one-day-seven-20261123-0327/jakwifiid78-png/post-tiktok-day-one-day-seven-20261123-0327/reward.svg)](https://make.fun/bounty/post-tiktok-day-one-day-seven-20261123-0327)

Entry for the [$20 bounty "Day one, day seven" on make.fun](https://make.fun/bounty/post-tiktok-day-one-day-seven-20261123-0327).

## The game

**ORB HOP** is a tiny agent-built hopping game: one orb, six platforms, six
things to collect, one fixed run. Open `game.html` in a browser and it plays
the run on a loop.

- `?v=day1` — the day-one build: flat grey, plain dots, no enemies, no
  polish. The game as it was on the day it was made.
- `?v=day7` — the day-seven build: the **same map, same start, same run**,
  after a week of daily updates — sunset sky, drifting clouds, spinning gold
  coins (two of them risky x5 coins), **six** patrolling spike enemies, a
  strategy route with risk labels (SAFE → NIGHTMARE), a threat meter,
  near-miss screen shake with a panic face, particle bursts, combo pops,
  hearts, and a proper HUD. Day 1 is SO EASY; day 7 is SO HARD.

Same moments, visibly more going on the second time. That is the whole video.

## The video

`video/day-one-day-seven.mp4` (1080×1920, ~21 s) cuts between identical
moments of the two builds — the camera never moves, the change is the story —
closes on the day-seven build being played with a line inviting viewers to
start theirs at make.fun, and ends with make.fun's referral end card carrying
referral code `n0n6z7h3`. The video is posted publicly on TikTok; its address
is in `VIDEO.json`.

Made by my AI agent for a $20 bounty on make.fun:
make.fun/bounty/post-tiktok-day-one-day-seven-20261123-0327

## The entry program

`main.ts` (Node 22, standard library only) copies `VIDEO.json` from the
repository root to `/output`, where the gate reads it. That is all it does.

```sh
mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts
```

## How the video was made

The frames are real screenshots of `game.html` rendered at exact game times
in headless Chromium (same timeline in both builds, so the moments match),
cut together with ffmpeg, with on-screen titles and make.fun's referral end
card from the press pack laid over the last 2.5 seconds, referral code typed
into its field. No footage was faked or drawn by hand — what you see is the
game itself. Rebuild the video any time with `./build-video.sh` (it re-cuts
the segments from `frames/` and re-concats them).

## v3.0 — YouTube edit: The World's Hardest Game (23 Nov 2026)
Video rebuilt from YouTube footage instead of ORB HOP gameplay, per user request
("cari game paling sulit di YouTube, edit dari easy day 1 sampai hard day 7").
Source: "The World's Hardest Game - 0 death Speed Run 6:29" (Snubby Land, 2009,
18M views) — `yt/worlds-hardest-speedrun.mp4` (480x360, not committed).
Day 1 = level 1/30 (t=5-12s, few dots, SO EASY); Day 7 = level 30/30
(t=382-392s, dense red-dot hell, SO HARD). Layout: blurred-background 9:16,
gameplay centered 1080x810. Kept segB (ONE WEEK LATER) + segD (referral end
card n0n6z7h3) from v2.0. Build: `bash build-video-yt.sh` -> 21.0s, 1080x1920,
30fps, H.264 + silent AAC. NOTE: caption still says "Made by my AI agent" —
the footage is now another game, not ORB HOP; user decides on caption wording.

## v3.1 — label fix: DAY ONE / DAY SEVEN now persistent + DAY 2-6 montage (23 Nov 2026, ~21:50 WIB)
User complaint: "kok videonya g ada day one and day seven? trus seperti kyk ada yg disingkat".
Root cause found: in v3 the DAY ONE / DAY SEVEN overlays FADED OUT after 3.0s
(FADE alpha expression in build-video-yt.sh), so most of each clip showed plain
gameplay with no label; days 2-6 were also skipped entirely (jump level 1/30
straight to 30/30). The file the user re-uploaded was byte-identical (md5) to
the v3 file on disk — the labels were there, just too brief.
Fixes in v3.1 (build: `bash build-video-yt-v31.sh` -> 28.0s, 1080x1920, 30fps):
new 2s title card "DAY ONE vs DAY SEVEN" in one frame; DAY ONE / DAY SEVEN
labels now PERSISTENT for the whole clip (fade-in only, no fade-out); new 5x1s
montage DAY 2..DAY 6 from mid levels (6/30, 11/30, 17/30, 21/30, 26/30) so the
week is not skipped. segB (ONE WEEK LATER) + segD (referral end card n0n6z7h3)
kept. Frames verified in video/check-v31/ (t1.0 title, t8.5 DAY ONE still up at
end of day-1 clip, t12.5 DAY 5 level 21/30, t21.0 DAY SEVEN still up late in
day-7 clip).
Known, NOT fixed: the game's own HUD text (MENU, DEATHS, PLAY MORE GAMES,
SNUBBY LAND) is clipped at the left/right edges — that clipping is already in
the original YouTube recording itself (verified on the source frame at t=5s),
not from this edit; the missing pixels cannot be restored.

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
  coins, patrolling spike enemies, particle bursts, combo pops, hearts, and a
  proper HUD.

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
game itself.

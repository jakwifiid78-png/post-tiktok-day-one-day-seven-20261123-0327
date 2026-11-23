// ORB HOP — "Day one, day seven" entry for make.fun (Node 22, standard library only).
//
// The entry itself is a TikTok video: the house reads the video's views and
// interactions from TikTok. This program's only job is to hand the video's
// address over — it copies VIDEO.json from the repository root to /output,
// where the gate reads it. Nothing else this program writes is scored.
//
// Run locally to check it:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts
// (out/VIDEO.json is then byte for byte this directory's VIDEO.json.)

import { copyFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

const botDir = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

mkdirSync(outDir, { recursive: true });

try {
  copyFileSync(join(botDir, 'VIDEO.json'), join(outDir, 'VIDEO.json'));
} catch (err) {
  console.error(`Could not copy VIDEO.json out of ${botDir}: ${(err as Error).message}`);
  process.exit(1);
}

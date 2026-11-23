// Film ORB HOP: drive headless Chromium over CDP, render game.html at exact
// game times, and save one PNG per frame. Same timeline in both builds, so
// identical moments match frame for frame.
// Usage: node capture.mjs
//   Reads:  game.html in this directory (via file:// URL)
//   Writes: frames/day1-000.png ... frames/day7-150.png

import { spawn } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const CHROME = '/home/hatch/.cache/ms-playwright/chromium_headless_shell-1255/chrome-headless-shell-linux64/chrome-headless-shell';
const GAME = 'file://' + join(HERE, 'game.html');
const FRAMES = join(HERE, 'frames');
const FPS = 15;

mkdirSync(FRAMES, { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const chrome = spawn(CHROME, [
  '--headless', '--no-sandbox', '--disable-gpu', '--hide-scrollbars',
  '--window-size=1080,1920',
  '--remote-debugging-port=9222',
  '--user-data-dir=/tmp/chrome-orbhop-profile',
  'about:blank',
], { stdio: 'ignore' });

// Wait for the DevTools endpoint.
let version = null;
for (let i = 0; i < 40; i++) {
  try {
    const res = await fetch('http://127.0.0.1:9222/json/version');
    if (res.ok) { version = await res.json(); break; }
  } catch { /* not up yet */ }
  await sleep(500);
}
if (!version) { console.error('chrome did not come up'); chrome.kill(); process.exit(1); }

const ws = new WebSocket(version.webSocketDebuggerUrl);
await new Promise((resolve, reject) => {
  ws.onopen = resolve;
  ws.onerror = reject;
});

let nextId = 1;
const pending = new Map();
let waiters = [];
ws.onmessage = (ev) => {
  const msg = JSON.parse(ev.data);
  if (msg.id && pending.has(msg.id)) {
    const { resolve, reject } = pending.get(msg.id);
    pending.delete(msg.id);
    msg.error ? reject(new Error(JSON.stringify(msg.error))) : resolve(msg.result);
  } else if (msg.method) {
    const hit = [];
    waiters = waiters.filter((w) => {
      const ok = msg.method === w.method && (!w.sessionId || msg.sessionId === w.sessionId);
      if (ok) hit.push(w);
      return !ok;
    });
    for (const w of hit) { clearTimeout(w.timer); w.resolve(msg); }
  }
};
function send(method, params = {}, sessionId) {
  const id = nextId++;
  const payload = { id, method, params };
  if (sessionId) payload.sessionId = sessionId;
  ws.send(JSON.stringify(payload));
  return new Promise((resolve, reject) => pending.set(id, { resolve, reject }));
}
function waitFor(method, sessionId, timeoutMs = 15000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('timeout waiting for ' + method)), timeoutMs);
    waiters.push({ method, sessionId, resolve, reject, timer });
  });
}

async function waitReady(sessionId) {
  for (let i = 0; i < 30; i++) {
    try {
      const r = await send('Runtime.evaluate', { expression: 'document.readyState', returnByValue: true }, sessionId);
      if (r && r.result && r.result.value === 'complete') return;
    } catch { /* target not ready yet */ }
    await sleep(300);
  }
  throw new Error('page never became ready');
}

async function film(versionName, tEnd) {
  const { targetId } = await send('Target.createTarget', { url: GAME + '?v=' + versionName });
  const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });
  await send('Page.enable', {}, sessionId);
  await send('Emulation.setDeviceMetricsOverride', {
    width: 1080, height: 1920, deviceScaleFactor: 1, mobile: false,
  }, sessionId);
  await waitReady(sessionId);
  await sleep(700); // let fonts settle
  const total = Math.round(tEnd * FPS);
  for (let i = 0; i <= total; i++) {
    const t = i / FPS;
    await send('Runtime.evaluate', { expression: `window.__setTime(${t})` }, sessionId);
    const shot = await send('Page.captureScreenshot', { format: 'png' }, sessionId);
    const name = `${versionName}-${String(i).padStart(3, '0')}.png`;
    writeFileSync(join(FRAMES, name), Buffer.from(shot.data, 'base64'));
    if (i % 30 === 0) console.log(versionName, i, '/', total, 't=' + t.toFixed(2));
  }
  await send('Target.closeTarget', { targetId });
  console.log('done', versionName, total + 1, 'frames');
}

try {
  await film('day1', 7);
  await film('day7', 10);
} finally {
  ws.close();
  chrome.kill();
  console.log('filmed');
}

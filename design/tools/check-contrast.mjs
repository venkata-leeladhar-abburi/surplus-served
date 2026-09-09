#!/usr/bin/env node
/**
 * Contrast gate for the Surplus → Served palette.
 *
 *   node design/tools/check-contrast.mjs
 *
 * Exits non-zero if any documented pairing drops below its WCAG 2.2 floor.
 * Wire this into CI — §10 commits the product to AA, so a token change that
 * quietly breaks it should fail the build, not ship.
 */

import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const T = JSON.parse(readFileSync(resolve(root, 'design/tokens/tokens.json'), 'utf8'));

const AA_TEXT = T.accessibility.minContrastBodyText; // 4.5
const AA_LARGE = T.accessibility.minContrastLargeText; // 3.0

const luminance = (hex) => {
  const h = hex.replace('#', '');
  const [r, g, b] = [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
  const f = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
};

const ratio = (a, b) => {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

const C = T.color;
const v = (x) => (x && typeof x === 'object' && 'value' in x ? x.value : x);

/** [label, foreground, background, floor] */
const checks = [
  ['ink on surface', v(C.neutral.ink), v(C.neutral.surface), AA_TEXT],
  ['inkSoft on surface', v(C.neutral.inkSoft), v(C.neutral.surface), AA_TEXT],
  ['ink on surfaceAlt', v(C.neutral.ink), v(C.neutral.surfaceAlt), AA_TEXT],
  ['white on leafGreen (primary button)', v(C.neutral.white), v(C.brand.leafGreen), AA_TEXT],
  ['ink on harvestOrange (accent button)', v(C.neutral.ink), v(C.brand.harvestOrange), AA_TEXT],
  ['white on tomatoRed (danger button)', v(C.neutral.white), v(C.brand.tomatoRed), AA_TEXT],
  ['leafGreen on green100 (chip)', v(C.brand.leafGreen), C.green['100'], AA_TEXT],
  ['border on surface (non-text)', v(C.neutral.border), v(C.neutral.surface), 1.0],
];

// Every semantic hue's onContainer tone against its own tint.
const containers = {
  success: '#E6F3EC',
  error: '#FDECEA',
  warning: '#FDF3E2',
  info: '#EAF0FE',
};
for (const [name, bg] of Object.entries(containers)) {
  const tone = C.semantic[name].onContainer;
  checks.push([`${name}.onContainer on its tint`, tone, bg, AA_TEXT]);
}

// Every status badge: label/icon tone against the badge surface.
for (const [name, s] of Object.entries(T.status)) {
  if (name.startsWith('$')) continue;
  checks.push([`status.${name} text on surface`, s.text, s.surface, AA_TEXT]);
}

let failed = 0;
console.log('\nContrast check — WCAG 2.2 AA\n');
for (const [label, fg, bg, floor] of checks) {
  const r = ratio(fg, bg);
  const ok = r >= floor;
  if (!ok) failed++;
  console.log(
    `  ${ok ? '✓' : '✗'} ${r.toFixed(2).padStart(5)}:1  (needs ${floor.toFixed(1)})  ${label}`,
  );
}

console.log(
  failed === 0
    ? `\nAll ${checks.length} pairings pass.\n`
    : `\n${failed} of ${checks.length} pairings FAIL.\n`,
);
process.exit(failed === 0 ? 0 : 1);

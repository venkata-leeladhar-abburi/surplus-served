#!/usr/bin/env node
/**
 * Surplus → Served — icon generator.
 *
 *   node design/tools/generate-icons.mjs
 *
 * One geometry source (design/icons/icons.mjs) → four outputs, so the app,
 * the admin console and the design files can never drift apart.
 *
 *   design/icons/svg/*.svg                                  designers / Figma
 *   design/icons/preview.html                               visual QA sheet
 *   packages/ss_design_system/lib/src/icons/ss_icons.g.dart  Flutter
 *   packages/web-ui/src/icons/icons.g.ts                     Next.js
 */

import { mkdirSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { icons, meta } from '../icons/icons.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');

const BANNER = [
  'GENERATED FILE — DO NOT EDIT.',
  'Source: design/icons/icons.mjs',
  'Regenerate: node design/tools/generate-icons.mjs',
];

const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();

const write = (rel, body) => {
  const p = resolve(root, rel);
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, body);
};

const names = Object.keys(icons).sort();
const bySet = (set) => names.filter((n) => icons[n].set === set);
const coreNames = bySet('core');
const categoryNames = bySet('category');
const uiNames = bySet('ui');
const filledNames = names.filter((n) => icons[n].filled);

/* ── SVG files ─────────────────────────────────────────────────────────── */

const svg = (def, variant) => {
  const isFilled = variant === 'filled';
  const paths = isFilled ? def.filled : def.outline;
  const attrs = isFilled
    ? `fill="currentColor" fill-rule="${def.fillRule ?? 'evenodd'}"`
    : `fill="none" stroke="currentColor" stroke-width="${meta.strokeWidth}" ` +
      `stroke-linecap="${meta.cap}" stroke-linejoin="${meta.join}"`;

  // A filled icon MUST be one <path>: fill-rule only applies within a single
  // path, so a hole drawn as a separate element would just fill solid.
  const els = isFilled
    ? [`  <path d="${paths.join(' ')}"/>`]
    : paths.map((d) => `  <path d="${d}"/>`);

  return [
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${meta.viewBox} ${meta.viewBox}"`,
    `     width="${meta.viewBox}" height="${meta.viewBox}" ${attrs}>`,
    ...els,
    '</svg>',
    '',
  ].join('\n');
};

const svgDir = resolve(root, 'design/icons/svg');
mkdirSync(svgDir, { recursive: true });
for (const f of readdirSync(svgDir)) rmSync(resolve(svgDir, f));

let svgCount = 0;
for (const name of names) {
  write(`design/icons/svg/${kebab(name)}.svg`, svg(icons[name], 'outline'));
  svgCount++;
  if (icons[name].filled) {
    write(`design/icons/svg/${kebab(name)}-filled.svg`, svg(icons[name], 'filled'));
    svgCount++;
  }
}

/* ── Flutter ───────────────────────────────────────────────────────────── */

const dartList = (paths) =>
  paths.map((d) => `      '${d}',`).join('\n');

const dartEntries = names
  .map((name) => {
    const def = icons[name];
    const filled = def.filled
      ? `\n    filled: <String>[\n${dartList(def.filled)}\n    ],`
      : '';
    const rule = def.fillRule === 'nonzero' ? '\n    fillNonZero: true,' : '';
    return `  /// ${def.set} · ${def.keywords.join(', ')}
  static const ${name} = SsIconData(
    name: '${name}',
    outline: <String>[
${dartList(def.outline)}
    ],${filled}${rule}
  );`;
  })
  .join('\n\n');

const dart = `${BANNER.map((l) => `// ${l}`).join('\n')}

import 'ss_icon.dart';

/// The Surplus → Served icon set (§05).
///
/// ${names.length} icons — ${coreNames.length} core, ${categoryNames.length} category, ${uiNames.length} UI.
/// ${filledNames.length} carry a filled variant, used for active states and
/// primary actions (§05.4).
///
/// Render with [SsIcon]:
///
/// \`\`\`dart
/// SsIcon(SsIcons.leaf, size: SsIconSize.md, color: context.ssColors.primary)
/// SsIcon(SsIcons.home, filled: true)
/// \`\`\`
abstract final class SsIcons {
${dartEntries}

  /// Every icon, keyed by name — for dynamic lookup from API payloads such as
  /// [SsStatus.iconName]. Prefer the named constants in app code.
  static const Map<String, SsIconData> all = <String, SsIconData>{
${names.map((n) => `    '${n}': ${n},`).join('\n')}
  };

  static const List<String> coreNames = <String>[
${coreNames.map((n) => `    '${n}',`).join('\n')}
  ];
}
`;

write('packages/ss_design_system/lib/src/icons/ss_icons.g.dart', dart);

/* ── Web ───────────────────────────────────────────────────────────────── */

const tsEntries = names
  .map((name) => {
    const def = icons[name];
    const parts = [
      `    set: '${def.set}'`,
      `    outline: [${def.outline.map((d) => `'${d}'`).join(', ')}]`,
    ];
    if (def.filled) parts.push(`    filled: [${def.filled.map((d) => `'${d}'`).join(', ')}]`);
    if (def.fillRule === 'nonzero') parts.push(`    fillRule: 'nonzero' as const`);
    return `  ${name}: {\n${parts.join(',\n')},\n  },`;
  })
  .join('\n');

const ts = `${BANNER.map((l) => `// ${l}`).join('\n')}

export const iconMeta = {
  viewBox: ${meta.viewBox},
  strokeWidth: ${meta.strokeWidth},
  cap: '${meta.cap}',
  join: '${meta.join}',
} as const;

export const iconPaths = {
${tsEntries}
} as const;

export type IconName = keyof typeof iconPaths;

export const iconNames = Object.keys(iconPaths) as IconName[];

export const coreIconNames = iconNames.filter((n) => iconPaths[n].set === 'core');
`;

write('packages/web-ui/src/icons/icons.g.ts', ts);

/* ── Preview sheet ─────────────────────────────────────────────────────── */

const cell = (name, variant) => {
  const def = icons[name];
  const paths = variant === 'filled' ? def.filled : def.outline;
  const attrs =
    variant === 'filled'
      ? `fill="currentColor" fill-rule="${def.fillRule ?? 'evenodd'}"`
      : `fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"`;
  const els =
    variant === 'filled'
      ? `<path d="${paths.join(' ')}"/>`
      : paths.map((d) => `<path d="${d}"/>`).join('');
  return `<figure>
  <svg viewBox="0 0 24 24" ${attrs}>${els}</svg>
  <figcaption>${name}</figcaption>
</figure>`;
};

const sizes = [14, 16, 20, 24, 32, 48];
const preview = `<!doctype html>
<meta charset="utf-8">
<title>Surplus → Served — icon sheet</title>
<style>
  :root { --ink:#15211B; --green:#1F6B4A; --border:#D9E1D6; --surface:#FAFBF7; }
  body { margin:0; padding:32px; background:var(--surface); color:var(--ink);
         font:14px/1.6 system-ui,-apple-system,sans-serif; }
  h1 { font-size:28px; margin:0 0 4px; }
  h2 { font-size:16px; margin:40px 0 12px; color:var(--green);
       border-bottom:1px solid var(--border); padding-bottom:8px; }
  p.sub { margin:0 0 8px; color:#4A574F; }
  .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(104px,1fr)); gap:8px; }
  figure { margin:0; padding:14px 6px; background:#fff; border:1px solid var(--border);
           border-radius:12px; text-align:center; color:var(--green); }
  figure svg { width:32px; height:32px; display:block; margin:0 auto 8px; }
  figcaption { font-size:11px; color:#4A574F; word-break:break-word; }
  .scale { display:flex; align-items:flex-end; gap:24px; padding:20px; background:#fff;
           border:1px solid var(--border); border-radius:12px; color:var(--green); }
  .scale div { text-align:center; font-size:11px; color:#4A574F; }
  .dark { background:#0D1512; color:#EAF1EC; border-radius:12px; padding:20px; margin-top:12px; }
  .dark figure { background:#141F1A; border-color:#2C3A33; color:#4CAF7A; }
  .dark figcaption { color:#AFBDB4; }
</style>
<h1>Surplus → Served — icon set</h1>
<p class="sub">${names.length} icons · ${coreNames.length} core / ${categoryNames.length} category / ${uiNames.length} UI · ${meta.strokeWidth}px stroke · ${meta.viewBox}px grid · round caps and joins</p>

<h2>Size scale (§05.6) — visual weight holds from 16 to 48</h2>
<div class="scale">
  ${sizes
    .map(
      (s) =>
        `<div><svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${icons.leaf.outline
          .map((d) => `<path d="${d}"/>`)
          .join('')}</svg><br>${s}px</div>`,
    )
    .join('')}
</div>

<h2>Core — outline (§05.3)</h2>
<div class="grid">${coreNames.map((n) => cell(n, 'outline')).join('')}</div>

<h2>Core — filled (§05.4)</h2>
<div class="grid">${filledNames.map((n) => cell(n, 'filled')).join('')}</div>

<h2>Category (§05.5)</h2>
<div class="grid">${categoryNames.map((n) => cell(n, 'outline')).join('')}</div>

<h2>UI — interface furniture for §06 / §07 components</h2>
<div class="grid">${uiNames.map((n) => cell(n, 'outline')).join('')}</div>

<h2>Dark theme check (§03 "test in both light and dark")</h2>
<div class="dark"><div class="grid">${coreNames
  .map((n) => cell(n, 'outline'))
  .join('')}</div></div>
`;

write('design/icons/preview.html', preview);

/* ── Report ────────────────────────────────────────────────────────────── */

console.log(`\nSurplus → Served — icon set\n`);
console.log(`  ${names.length} icons  (${coreNames.length} core, ${categoryNames.length} category, ${uiNames.length} UI)`);
console.log(`  ${filledNames.length} filled variants`);
console.log(`  ${svgCount} SVG files              → design/icons/svg/`);
console.log(`  Flutter                    → packages/ss_design_system/lib/src/icons/ss_icons.g.dart`);
console.log(`  TypeScript                 → packages/web-ui/src/icons/icons.g.ts`);
console.log(`  Preview sheet              → design/icons/preview.html\n`);

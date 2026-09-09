#!/usr/bin/env node
/**
 * Surplus → Served — design token generator.
 *
 *   node design/tools/generate.mjs
 *
 * Reads design/tokens/tokens.json and emits platform themes. Every file it
 * writes carries a DO NOT EDIT banner: change tokens.json and re-run instead.
 *
 * Outputs:
 *   packages/ss_design_system/lib/src/tokens/tokens.g.dart   (Flutter)
 *   packages/web-ui/src/tokens/tokens.g.ts                   (Next.js / MUI)
 *   packages/web-ui/src/tokens/tokens.g.css                  (CSS custom properties)
 */

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const T = JSON.parse(readFileSync(resolve(root, 'design/tokens/tokens.json'), 'utf8'));

const BANNER = (lang) => {
  const c = lang === 'css' ? ['/*', '*/'] : ['//', ''];
  const line = (s) => (lang === 'css' ? `   ${s}` : `${c[0]} ${s}`);
  return [
    lang === 'css' ? '/*' : `${c[0]} GENERATED FILE — DO NOT EDIT.`,
    lang === 'css' ? line('GENERATED FILE — DO NOT EDIT.') : line('Source: design/tokens/tokens.json'),
    lang === 'css' ? line('Source: design/tokens/tokens.json') : line(`Design System v${T.$meta.version}`),
    lang === 'css' ? line(`Design System v${T.$meta.version}`) : line('Regenerate: node design/tools/generate.mjs'),
    lang === 'css' ? line('Regenerate: node design/tools/generate.mjs') : '',
    lang === 'css' ? '*/' : '',
  ].filter(Boolean).join('\n');
};

const val = (v) => (v && typeof v === 'object' && 'value' in v ? v.value : v);
const hexToDart = (hex) => `Color(0xFF${hex.replace('#', '').toUpperCase()})`;
const camel = (s) => s.replace(/[-_ ](\w)/g, (_, c) => c.toUpperCase());
const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
const dartKey = (k) => (/^\d/.test(k) ? `n${k}` : camel(k));

const write = (rel, body) => {
  const p = resolve(root, rel);
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, body.replace(/\n{3,}/g, '\n\n').trimEnd() + '\n');
  console.log('  ✓', rel);
};

/* ── flatten helpers ───────────────────────────────────────────────── */
const colorEntries = [];
for (const [k, v] of Object.entries(T.color.brand)) colorEntries.push([k, val(v)]);
for (const [k, v] of Object.entries(T.color.green)) colorEntries.push([`green${k}`, val(v)]);
for (const [k, v] of Object.entries(T.color.neutral)) colorEntries.push([k, val(v)]);
for (const [k, v] of Object.entries(T.color.semantic)) {
  colorEntries.push([k, val(v)]);
  if (v.onContainer) colorEntries.push([`on${k[0].toUpperCase()}${k.slice(1)}Container`, v.onContainer]);
}

/* ── Flutter ───────────────────────────────────────────────────────── */
function dart() {
  const colors = colorEntries
    .map(([k, hex]) => `  static const ${dartKey(k)} = ${hexToDart(hex)};`)
    .join('\n');

  const gradients = Object.entries(T.color.gradient)
    .map(([k, g]) => `  static const ${camel(k)} = [${hexToDart(g.from)}, ${hexToDart(g.to)}];`)
    .join('\n');

  const spacing = Object.entries(T.spacing)
    .filter(([k]) => !k.startsWith('$'))
    .map(([k, v]) => `  static const double ${dartKey(k)} = ${Number(v).toFixed(1)};`)
    .join('\n');

  const radii = Object.entries(T.radius)
    .map(([k, v]) => `  static const double ${dartKey(k)} = ${Number(v).toFixed(1)};`)
    .join('\n');

  const iconSizes = Object.entries(T.iconography.sizes)
    .map(([k, v]) => `  static const double ${dartKey(k)} = ${Number(v).toFixed(1)};`)
    .join('\n');

  const durations = Object.entries(T.motion.duration)
    .map(([k, v]) => `  static const ${camel(k)} = Duration(milliseconds: ${v});`)
    .join('\n');

  const shadows = Object.entries(T.elevation)
    .map(([k, e]) => {
      if (e.opacity === 0) return `  static const List<BoxShadow> ${camel(k)} = <BoxShadow>[];`;
      return `  static const List<BoxShadow> ${camel(k)} = [
    BoxShadow(
      color: Color(0x${Math.round(e.opacity * 255).toString(16).padStart(2, '0').toUpperCase()}${e.color.replace('#', '').toUpperCase()}),
      offset: Offset(0, ${Number(e.y).toFixed(1)}),
      blurRadius: ${Number(e.blur).toFixed(1)},
      spreadRadius: ${Number(e.spread).toFixed(1)},
    ),
  ];`;
    })
    .join('\n');

  const type = Object.entries(T.typography.scale)
    .map(([k, s]) => `  static const ${camel(k)} = TextStyle(
    fontFamily: '${s.family}',
    fontWeight: FontWeight.w${s.weight},
    fontVariations: [FontVariation('wght', ${Number(s.weight).toFixed(1)})],
    fontSize: ${Number(s.size).toFixed(1)},
    height: ${Number(s.lineHeight).toFixed(2)},${s.italic ? '\n    fontStyle: FontStyle.italic,' : ''}
  );`)
    .join('\n\n');

  const statuses = Object.entries(T.status)
    .filter(([k]) => !k.startsWith('$'))
    .map(([k, s]) => `  ${camel(k)}(${hexToDart(s.color)}, ${hexToDart(s.text)}, ${hexToDart(s.surface)}, '${s.icon}', '${s.labelEn}')`)
    .join(',\n');

  return `${BANNER('dart')}

// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Raw colour primitives. Prefer [SsColors] via \`Theme.of(context).extension\`
/// in feature code; reach for these only inside the design system itself.
abstract final class SsPalette {
${colors}
}

abstract final class SsGradients {
${gradients}
}

abstract final class SsSpacing {
${spacing}
}

abstract final class SsRadius {
${radii}
}

abstract final class SsIconSize {
  static const double stroke = ${Number(T.iconography.strokeWidth).toFixed(1)};
${iconSizes}
}

abstract final class SsDuration {
${durations}
}

abstract final class SsShadows {
${shadows}
}

abstract final class SsTypeScale {
${type}
}

abstract final class SsA11y {
  static const double minTapTarget = ${Number(T.accessibility.minTapTarget).toFixed(1)};
  static const double textScaleMax = ${Number(T.accessibility.textScaleMax).toFixed(1)};
  static const double focusRingWidth = ${Number(T.accessibility.focusRing.width).toFixed(1)};
  static const double focusRingOffset = ${Number(T.accessibility.focusRing.offset).toFixed(1)};
  static const Color focusRingColor = ${hexToDart(T.accessibility.focusRing.color)};
}

abstract final class SsBreakpoints {
${Object.entries(T.breakpoints).map(([k, v]) => `  static const double ${dartKey(k)} = ${Number(v).toFixed(1)};`).join('\n')}
}

/// Donation lifecycle status → colour, surface, icon name, English label.
/// Colour is never the only signal: always render the icon and label too.
enum SsStatus {
${statuses};

  const SsStatus(this.color, this.text, this.surface, this.iconName, this.labelEn);

  /// Brand hue — for fills, dots and large shapes.
  final Color color;

  /// AA-verified label/icon tone on [surface] (>= 4.5:1).
  final Color text;

  final Color surface;
  final String iconName;
  final String labelEn;
}
`;
}

/* ── Web (TS) ──────────────────────────────────────────────────────── */
function ts() {
  const obj = (o, indent = 2) =>
    JSON.stringify(o, null, indent).replace(/"([A-Za-z_$][\w$]*)":/g, '$1:');

  const colors = Object.fromEntries(colorEntries);
  const gradients = Object.fromEntries(
    Object.entries(T.color.gradient).map(([k, g]) => [
      k,
      `linear-gradient(135deg, ${g.from} 0%, ${g.to} 100%)`,
    ]),
  );
  const typography = Object.fromEntries(
    Object.entries(T.typography.scale).map(([k, s]) => [
      k,
      {
        fontFamily: `'${s.family}', ${s.family === 'Lora' ? 'Georgia, serif' : 'system-ui, sans-serif'}`,
        fontWeight: s.weight,
        fontSize: `${s.size / 16}rem`,
        lineHeight: s.lineHeight,
        ...(s.italic ? { fontStyle: 'italic' } : {}),
      },
    ]),
  );
  const shadows = Object.fromEntries(
    Object.entries(T.elevation).map(([k, e]) => [
      k,
      e.opacity === 0
        ? 'none'
        : `0 ${e.y}px ${e.blur}px ${e.spread}px rgba(21, 33, 27, ${e.opacity})`,
    ]),
  );
  const status = Object.fromEntries(
    Object.entries(T.status).filter(([k]) => !k.startsWith('$')),
  );

  return `${BANNER('ts')}

export const colors = ${obj(colors)} as const;

export const gradients = ${obj(gradients)} as const;

export const spacing = ${obj(Object.fromEntries(Object.entries(T.spacing).filter(([k]) => !k.startsWith('$'))))} as const;

export const radius = ${obj(T.radius)} as const;

export const shadows = ${obj(shadows)} as const;

export const typography = ${obj(typography)} as const;

export const iconSize = ${obj(T.iconography.sizes)} as const;

export const iconStroke = ${T.iconography.strokeWidth};

export const motion = ${obj(T.motion)} as const;

export const breakpoints = ${obj(T.breakpoints)} as const;

export const a11y = ${obj(T.accessibility)} as const;

export const status = ${obj(status)} as const;

export type ColorToken = keyof typeof colors;
export type SpacingToken = keyof typeof spacing;
export type RadiusToken = keyof typeof radius;
export type StatusToken = keyof typeof status;
`;
}

/* ── CSS custom properties ─────────────────────────────────────────── */
function css() {
  const lines = [];
  for (const [k, hex] of colorEntries) lines.push(`  --ss-color-${kebab(k)}: ${hex};`);
  for (const [k, g] of Object.entries(T.color.gradient))
    lines.push(`  --ss-gradient-${kebab(k)}: linear-gradient(135deg, ${g.from} 0%, ${g.to} 100%);`);
  for (const [k, v] of Object.entries(T.spacing))
    if (!k.startsWith('$')) lines.push(`  --ss-space-${kebab(k)}: ${v}px;`);
  for (const [k, v] of Object.entries(T.radius))
    lines.push(`  --ss-radius-${kebab(k)}: ${v === 999 ? '999px' : `${v}px`};`);
  for (const [k, e] of Object.entries(T.elevation))
    lines.push(
      `  --ss-shadow-${kebab(k)}: ${e.opacity === 0 ? 'none' : `0 ${e.y}px ${e.blur}px ${e.spread}px rgba(21, 33, 27, ${e.opacity})`};`,
    );
  for (const [k, s] of Object.entries(T.typography.scale)) {
    lines.push(`  --ss-font-${kebab(k)}-size: ${s.size / 16}rem;`);
    lines.push(`  --ss-font-${kebab(k)}-line: ${s.lineHeight};`);
    lines.push(`  --ss-font-${kebab(k)}-weight: ${s.weight};`);
  }
  lines.push(`  --ss-font-primary: 'Inter', system-ui, -apple-system, sans-serif;`);
  lines.push(`  --ss-font-secondary: 'Lora', Georgia, serif;`);
  lines.push(`  --ss-icon-stroke: ${T.iconography.strokeWidth}px;`);
  lines.push(`  --ss-tap-target: ${T.accessibility.minTapTarget}px;`);

  return `${BANNER('css')}

:root {
${lines.join('\n')}
}
`;
}

console.log(`\nSurplus → Served — generating design tokens v${T.$meta.version}\n`);
write('packages/ss_design_system/lib/src/tokens/tokens.g.dart', dart());
write('packages/web-ui/src/tokens/tokens.g.ts', ts());
write('packages/web-ui/src/tokens/tokens.g.css', css());
console.log('\nDone.\n');

#!/usr/bin/env node
/**
 * Surplus → Served — artwork code generation.
 *
 *   node design/tools/generate-artwork.mjs
 *
 * Reads design/assets/manifest.json (written by extract_artwork.py) and:
 *   · copies the PNGs into each package's asset folder
 *   · generates the Flutter catalogue and the TypeScript manifest
 *   · writes a preview sheet
 *
 * Run `python3 design/tools/extract_artwork.py` first if the crops have
 * changed; this step only turns them into code.
 */

import { copyFileSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const manifest = JSON.parse(readFileSync(resolve(root, 'design/assets/manifest.json'), 'utf8'));

const BANNER = [
  'GENERATED FILE — DO NOT EDIT.',
  'Source: design/assets/manifest.json (see design/tools/extract_artwork.py)',
  'Regenerate: python3 design/tools/extract_artwork.py && node design/tools/generate-artwork.mjs',
];

const write = (rel, body) => {
  const p = resolve(root, rel);
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, body);
};

const syncAssets = (destRel) => {
  for (const kind of ['illustrations', 'brand']) {
    const dest = resolve(root, destRel, kind);
    mkdirSync(dest, { recursive: true });
    for (const f of readdirSync(dest)) {
      if (f.endsWith('.png')) rmSync(resolve(dest, f));
    }
    for (const item of manifest[kind]) {
      copyFileSync(resolve(root, 'design', item.asset), resolve(dest, `${item.name}.png`));
    }
  }
};

syncAssets('packages/ss_design_system/assets');
syncAssets('packages/web-ui/assets');

/* ── Flutter ───────────────────────────────────────────────────────────── */

const dartEntry = (item, kind) => `  /// ${item.caption}
  static const ${item.name} = SsArtwork(
    name: '${item.name}',
    asset: 'assets/${kind}/${item.name}.png',
    caption: ${JSON.stringify(item.caption)},
    nativeWidth: ${item.width},
    nativeHeight: ${item.height},${item.set ? `\n    set: '${item.set}',` : ''}
  );`;

const dart = `${BANNER.map((l) => `// ${l}`).join('\n')}

import 'ss_artwork.dart';

/// The illustration set from §09 of the design document.
///
/// ${manifest.illustrations.length} illustrations, cropped from the document itself. Render with
/// [SsIllustration]:
///
/// \`\`\`dart
/// SsIllustration(SsIllustrations.noFoodAvailable, width: 160)
/// \`\`\`
///
/// Each entry carries its native pixel size. Going much beyond
/// [SsArtwork.nativeWidth] will look soft — the document is a flattened
/// raster and that is the resolution ceiling it contains.
abstract final class SsIllustrations {
${manifest.illustrations.map((i) => dartEntry(i, 'illustrations')).join('\n\n')}

  static const Map<String, SsArtwork> all = <String, SsArtwork>{
${manifest.illustrations.map((i) => `    '${i.name}': ${i.name},`).join('\n')}
  };

  /// Illustrations grouped by the section of §09 they came from.
  static const Map<String, List<SsArtwork>> bySet = <String, List<SsArtwork>>{
${[...new Set(manifest.illustrations.map((i) => i.set))]
  .map(
    (s) =>
      `    '${s}': <SsArtwork>[${manifest.illustrations
        .filter((i) => i.set === s)
        .map((i) => i.name)
        .join(', ')}],`,
  )
  .join('\n')}
  };
}

/// The logo and brand marks from §02 of the design document.
abstract final class SsBrandArt {
${manifest.brand.map((b) => dartEntry(b, 'brand')).join('\n\n')}

  static const Map<String, SsArtwork> all = <String, SsArtwork>{
${manifest.brand.map((b) => `    '${b.name}': ${b.name},`).join('\n')}
  };
}
`;

write('packages/ss_design_system/lib/src/artwork/ss_artwork.g.dart', dart);

/* ── Web ───────────────────────────────────────────────────────────────── */

const tsEntry = (item, kind) =>
  `  ${item.name}: {
    name: '${item.name}',
    src: '/artwork/${kind}/${item.name}.png',
    caption: ${JSON.stringify(item.caption)},
    nativeWidth: ${item.width},
    nativeHeight: ${item.height},${item.set ? `\n    set: '${item.set}',` : ''}
  },`;

const ts = `${BANNER.map((l) => `// ${l}`).join('\n')}

export interface Artwork {
  name: string;
  /** Path under the app's public directory. See README for the copy step. */
  src: string;
  caption: string;
  /** Beyond this width the asset softens — it is a crop from a raster PDF. */
  nativeWidth: number;
  nativeHeight: number;
  set?: string;
}

export const illustrations = {
${manifest.illustrations.map((i) => tsEntry(i, 'illustrations')).join('\n')}
} satisfies Record<string, Artwork>;

export const brandArt = {
${manifest.brand.map((b) => tsEntry(b, 'brand')).join('\n')}
} satisfies Record<string, Artwork>;

export type IllustrationName = keyof typeof illustrations;
export type BrandArtName = keyof typeof brandArt;

export const illustrationNames = Object.keys(illustrations) as IllustrationName[];
export const brandArtNames = Object.keys(brandArt) as BrandArtName[];

export const illustrationsBySet: Record<string, IllustrationName[]> = {
${[...new Set(manifest.illustrations.map((i) => i.set))]
  .map(
    (s) =>
      `  ${s}: [${manifest.illustrations
        .filter((i) => i.set === s)
        .map((i) => `'${i.name}'`)
        .join(', ')}],`,
  )
  .join('\n')}
};
`;

write('packages/web-ui/src/artwork/artwork.g.ts', ts);

/* ── Preview ───────────────────────────────────────────────────────────── */

const card = (item, kind) => `
  <figure>
    <img src="${kind}/${item.name}.png" alt="${item.caption}" width="${item.width}">
    <figcaption><code>${item.name}</code><br>${item.caption}<br><small>${item.width} × ${item.height}</small></figcaption>
  </figure>`;

const preview = `<!doctype html>
<meta charset="utf-8">
<title>Surplus → Served — artwork</title>
<style>
  body { margin:0; padding:32px; background:#FAFBF7; color:#15211B;
         font:14px/1.6 system-ui,-apple-system,sans-serif; }
  h1 { font-size:28px; margin:0 0 4px; }
  h2 { font-size:15px; color:#1F6B4A; border-bottom:1px solid #D9E1D6;
       padding-bottom:8px; margin:32px 0 14px; text-transform:capitalize; }
  p.sub { margin:0; color:#4A574F; }
  .note { background:#FDF3E2; border:1px solid #F6C453; border-radius:10px;
          padding:12px 16px; margin:16px 0 0; color:#A95C04; font-size:13px; }
  .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(190px,1fr)); gap:14px; }
  figure { margin:0; padding:14px; background:#fff; border:1px solid #D9E1D6;
           border-radius:14px; text-align:center; }
  figure img { max-width:100%; height:auto; }
  figcaption { font-size:11px; color:#4A574F; margin-top:10px; }
  code { color:#1F6B4A; }
  .dark { background:#0D1512; border-radius:14px; padding:20px; margin-top:12px; }
  .dark figure { background:#141F1A; border-color:#2C3A33; }
  .dark figcaption { color:#AFBDB4; }
</style>
<h1>Surplus → Served — artwork</h1>
<p class="sub">${manifest.illustrations.length} illustrations · ${manifest.brand.length} brand marks · cropped from the design document, backgrounds knocked out</p>
<div class="note"><strong>Resolution ceiling.</strong> The design PDF is a flattened raster, so these are the full resolution the document contains (80–190&nbsp;px wide). Fine at the sizes shown; soft if enlarged. Drop in the designer's original exports over the same filenames when they arrive.</div>

<h2>Brand (§02)</h2>
<div class="grid">${manifest.brand.map((b) => card(b, 'brand')).join('')}</div>

<h2>Brand on dark</h2>
<div class="dark"><div class="grid">${manifest.brand.map((b) => card(b, 'brand')).join('')}</div></div>

${[...new Set(manifest.illustrations.map((i) => i.set))]
  .map(
    (s) => `<h2>${s} (§09)</h2>
<div class="grid">${manifest.illustrations
      .filter((i) => i.set === s)
      .map((i) => card(i, 'illustrations'))
      .join('')}</div>`,
  )
  .join('\n')}

<h2>All illustrations on dark</h2>
<div class="dark"><div class="grid">${manifest.illustrations
  .map((i) => card(i, 'illustrations'))
  .join('')}</div></div>
`;

write('design/assets/preview.html', preview);

console.log('\nSurplus → Served — artwork\n');
console.log(`  ${manifest.illustrations.length} illustrations, ${manifest.brand.length} brand marks`);
console.log('  assets  → packages/ss_design_system/assets/, packages/web-ui/assets/');
console.log('  Flutter → packages/ss_design_system/lib/src/artwork/ss_artwork.g.dart');
console.log('  Web     → packages/web-ui/src/artwork/artwork.g.ts');
console.log('  Preview → design/assets/preview.html\n');

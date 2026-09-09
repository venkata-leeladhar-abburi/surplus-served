#!/usr/bin/env node
/**
 * Bundles the web design system gallery and copies the artwork it needs.
 *
 *   npm --workspace @surplus-served/web-ui run demo
 *
 * The gallery is the web counterpart of the Flutter golden sheets: somewhere to
 * actually look at every React component rather than trusting that it compiles.
 */
import { cpSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import * as esbuild from 'esbuild';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const demo = resolve(root, 'packages/web-ui/demo');

// artwork.g.ts refers to assets by their public path, so mirror that layout.
const artwork = resolve(demo, 'artwork');
rmSync(artwork, { recursive: true, force: true });
mkdirSync(artwork, { recursive: true });
cpSync(resolve(root, 'packages/web-ui/assets'), artwork, { recursive: true });

await esbuild.build({
  entryPoints: [resolve(demo, 'main.tsx')],
  outfile: resolve(demo, 'bundle.js'),
  bundle: true,
  format: 'iife',
  target: 'es2020',
  jsx: 'automatic',
  loader: { '.png': 'file' },
  define: { 'process.env.NODE_ENV': '"development"' },
  logLevel: 'info',
});

// Stamp the script tag so a rebuild is never masked by a cached bundle.
writeFileSync(
  resolve(demo, 'index.html'),
  `<!doctype html>
<meta charset="utf-8">
<title>Surplus → Served — web design system</title>
<style>
  html, body { margin: 0; }
  #root { min-height: 100vh; }
</style>
<div id="root"></div>
<script src="bundle.js?t=${Date.now()}"></script>
`,
);

# Surplus → Served

A three-sided platform — **Donor · Receiver (verified NGOs) · Admin** — that moves surplus
cooked food to the NGOs who can use it before it spoils.

> Food has a safe window measured in hours, not days. Every flow here exists to shrink the
> time between "food is ready" and "food is collected."

## What's here today

| Path | What it is |
| --- | --- |
| [`design/tokens/tokens.json`](design/tokens/tokens.json) | Colour, type, spacing, motion, status — the token source. |
| [`design/icons/icons.mjs`](design/icons/icons.mjs) | All 59 icons, drawn as geometry. |
| [`design/assets/`](design/assets) | 40 illustrations + 5 brand marks, cropped from the design artwork. |
| [`design/tools/`](design/tools) | Generators — tokens, icons, artwork, and the WCAG gate. |
| [`packages/ss_design_system`](packages/ss_design_system) | Flutter theme, 44 components, icons, artwork (57 tests passing) |
| [`packages/web-ui`](packages/web-ui) | MUI theme, 12 React components, icons, artwork |
| [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md) | The system, written out — including the 3 places it deviates from the source PDF |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Repo layout and service architecture for the full stack |

## Working on the design system

```bash
npm run design        # regenerate tokens, icons and artwork
npm run design:check  # verify WCAG 2.2 AA before committing
npm run verify        # everything above, plus the web typecheck
```

Re-cropping the illustrations and logo from the design PDF (only when the document
changes — it needs Python):

```bash
pip install pypdf pillow numpy && npm run design:extract
```

```bash
cd packages/ss_design_system && flutter analyze && flutter test
```

Never hand-edit a `*.g.dart`, `*.g.ts` or `*.g.css` file — change the JSON and regenerate.
CI fails if generated output is stale or if any documented colour pairing drops below AA.

## Using it

```dart
import 'package:ss_design_system/ss_design_system.dart';

MaterialApp(
  theme: SsTheme.light(),
  darkTheme: SsTheme.dark(),
  home: const FeedScreen(),
);
```

```tsx
import { ThemeProvider } from '@mui/material/styles';
import { lightTheme, SsIcon, SsIllustration, Logo } from '@surplus-served/web-ui';

<ThemeProvider theme={lightTheme}>{children}</ThemeProvider>
```

The Next.js app serves the artwork from `/public/artwork` — copy it in at build time:

```bash
cp -r packages/web-ui/assets/. apps/admin/public/artwork/
```

## Seeing the components

`packages/ss_design_system/test/golden/goldens/*.png` is the gallery — every component
rendered by Flutter, not mocked up. It doubles as the visual regression check:

```bash
cd packages/ss_design_system
flutter test test/golden                  # fail if anything shifted
flutter test --update-goldens test/golden # re-render after an intended change
```

| Sheet | Contents |
| --- | --- |
| `01_foundations` | Colour, green scale, full type scale, the three logo lockups |
| `02_components_light` / `_dark` | Buttons, badges, tags, inputs, filters, tabs, progress, stepper, alerts, pickup code |
| `03_cards_lists_nav` | Donation cards, freshness rings, avatars, list items, notifications, location, accordion, bottom nav, pagination, file upload |
| `04_states_and_artwork` | Empty states with §09 artwork, illustrations, all 59 icons |
| `05_selectors_table_map` | Dropdowns, selection controls, slider, date/time, filter bar, tabs, top nav, data table, map card, stat card |

Other previews: `design/icons/preview.html`, `design/assets/preview.html`.

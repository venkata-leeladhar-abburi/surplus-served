# Surplus → Served — Design System v1.0

> Good food lives on.

This is the written form of `Surplus-> Served.pdf` (Design System v1.0, sections 01–12),
turned into something a build can consume. The values here are **not** a re-interpretation —
they are transcribed from the source document, with the deviations recorded in
[§13 Deviations](#13-deviations-from-the-pdf) and the outstanding gaps in
[§15 What is still missing](#15-what-is-still-missing).

**Sources of truth**, each with a generator that fans it out to every platform:

| Source | What it defines | Generator |
| --- | --- | --- |
| [`design/tokens/tokens.json`](../design/tokens/tokens.json) | colour, type, spacing, radius, motion, status | `design/tools/generate.mjs` |
| [`design/icons/icons.mjs`](../design/icons/icons.mjs) | all 59 icons, as geometry | `design/tools/generate-icons.mjs` |
| [`design/assets/manifest.json`](../design/assets/manifest.json) | the illustrations and logo cropped from the PDF | `design/tools/generate-artwork.mjs` |

```bash
npm run design        # regenerate everything
npm run design:check  # WCAG contrast gate
```

| Output | Consumer |
| --- | --- |
| `packages/ss_design_system/lib/src/tokens/tokens.g.dart` | Flutter app |
| `packages/ss_design_system/lib/src/icons/ss_icons.g.dart` | Flutter app |
| `packages/ss_design_system/lib/src/artwork/ss_artwork.g.dart` | Flutter app |
| `packages/web-ui/src/tokens/tokens.g.{ts,css}` | Next.js admin (MUI) |
| `packages/web-ui/src/icons/icons.g.ts` | Next.js admin |
| `packages/web-ui/src/artwork/artwork.g.ts` | Next.js admin |

Never hand-edit a `*.g.*` file. Change the source, regenerate, commit both.

---

## 01. Introduction

A unified design language to reduce food waste, connect communities, and make fresh food
accessible to all. Simple. Inclusive. Impactful.

Four pillars: **Less Waste · Stronger Communities · Healthier Lives · A Kinder Planet.**

The product's hard constraint shapes every visual decision: cooked food has a safe window
measured in **hours, not days**. Anything that adds a second between "food is ready" and
"food is collected" is a design defect, not a preference.

---

## 02. Brand

**Brand idea** — Move good food, before time runs out.

**Mission** — To make surplus food easy to share with people who need it, reducing waste and
strengthening local communities.

**Brand promise** — Every surplus has a next table.

**Brand statement** — Good food should keep moving.

### Personality

| Trait | Meaning |
| --- | --- |
| Human | Real people. Real care. |
| Urgent | Act before it's too late. |
| Trustworthy | Safe, transparent and reliable. |
| Hopeful | A brighter tomorrow. |

**We are:** compassionate · action-oriented · transparent · community-driven
**We are not:** judgmental · slow or passive · charity-centric · overly promotional

### Voice & tone

| Principle | In practice |
| --- | --- |
| Clear over clever | "12 meals nearby" |
| Warm over sentimental | "Pickup in 18 min" |
| Action-oriented over alarmist | "Food saved" |
| Respectful over charity-centric | "You're helping it reach a table." |

### Signature visual language

- **Movement thread** — the `→` shows food in motion. It is part of the wordmark, not decoration.
- **Leaf motif** — freshness and life.
- **Organic shapes** — warm, human, approachable.
- **Time & freshness ring** — a subtle reminder to act soon (`SsFreshnessRing`).
- **Real food imagery** — authentic, honest and local. Never stock-perfect plating.

### Logo

The three approved lockups plus the leaf mark and the movement arrow ship as assets,
cropped from §02.1 of the design document:

| Asset | Use |
| --- | --- |
| `logoHorizontal` | Primary. App bars, headers, email. |
| `logoStacked` | Where width is tight — splash, centred layouts. |
| `logoIcon` | Icon-only tile. |
| `leafMark` | The mark alone, no tile. |
| `movementArrow` | The §02.8 movement thread, for standalone use. |
| `logoHorizontalReversed`, `logoStackedReversed`, `leafMarkReversed` | For Ink, Leaf Green and photography. |

The reversed lockups are **derived**, not cropped: §02.9 approves Ink and Leaf
Green as backgrounds, but the document only supplies the colour mark, whose
wordmark is dark ink and disappears on them. `extract_artwork.py` lifts the
dark greens toward white and leaves the harvest-orange leaf alone. `SsLogo` and
`Logo` pick the reversed asset from the theme's brightness by default.

```dart
SsLogo.horizontal(height: 40)
SsLogo.stacked(height: 64)
SsLogo.mark(height: 32)
```

```tsx
<Logo variant="horizontal" height={40} />        {/* follows the theme */}
<Logo variant="horizontal" height={40} reversed /> {/* force, e.g. over a photo */}
```

### Logo rules

Clear space equals the height of the `S` — `SsLogoLockup` applies it. Minimum size 24px
digital / 10mm print; `SsLogo` clamps to it rather than rendering the mark illegibly.
Approved backgrounds: white, Soft Mint, Leaf Green, and photography with sufficient contrast.
Never recolour, restack, crowd, or substitute the wordmark — which is why `SsLogo` and `Logo`
take a size and nothing else.

### Brand principles

1. **Rescue first** — give good food a second chance.
2. **Trust by design** — safety, transparency and verification.
3. **Local by default** — stronger communities start nearby.
4. **Every action counts** — small actions, big collective impact.

---

## 03. Colors

A palette inspired by fresh food, nature and communities.

### Primary

| Token | Hex | Role |
| --- | --- | --- |
| `leafGreen` | `#1F6B4A` | Primary — nature, health, positive action |
| `sageGreen` | `#4CAF7A` | Secondary — lighter, friendly |
| `harvestOrange` | `#E39A1F` | Accent — energy, hope, the joy of sharing |
| `tomatoRed` | `#C2402B` | Alert — important actions and emphasis |
| `sunriseYellow` | `#F6C453` | Highlight |
| `earthBrown` | `#6B4F3B` | Neutral, for imagery and illustration |

### Neutrals

| Token | Hex | Use |
| --- | --- | --- |
| `ink` | `#15211B` | Primary text |
| `inkSoft` | `#4A574F` | Secondary text |
| `surface` | `#FAFBF7` | Main background |
| `surfaceAlt` | `#F2F4EE` | Secondary surface |
| `border` | `#D9E1D6` | Dividers and borders |
| `muted` | `#A3B1A7` | Disabled text and icons |

### Semantic

| Token | Hex | On tinted container | Meaning |
| --- | --- | --- | --- |
| `success` | `#16A34A` | `#107D38` | Completed actions, positive feedback |
| `error` | `#DC2626` | `#D32424` | Errors and critical alerts |
| `warning` | `#D97706` | `#A95C04` | Caution and important notices |
| `info` | `#2563EB` | `#2563EB` | Informational messages |
| `focus` | `#7C3AED` | `#7C3AED` | Focus states |

The saturated hue is a **fill** colour (buttons, dots, gradients). The "on container" tone
is the **text and icon** colour on that hue's pale surface — see [§13](#13-deviations-from-the-pdf).

### Green scale

`900 #0E3D2C` · `700 #1F6B4A` · `500 #4CAF7A` · `300 #A7D5B9` · `100 #E6F3EC` · `50 #F4FAF7`

### Gradients

- **Nature** `#1F6B4A → #4CAF7A` — hero sections, CTAs, key highlights.
- **Sunrise** `#E39A1F → #F6C453` — accents, illustrations, special highlights.

### Rules

- Use colour with purpose, not decoration.
- Maintain sufficient contrast (WCAG 2.2 AA).
- Be consistent across all platforms.
- **Combine colour with text or icons — never colour alone.**
- Use semantic colours for status and feedback.
- Test in both light and dark environments.

---

## 04. Typography

**Inter** for the interface. **Lora** for display headlines, pull quotes and brand moments.

| Style | Font | Weight | Size | Line height |
| --- | --- | --- | --- | --- |
| H1 | Inter | Bold 700 | 56 | 120% |
| H2 | Inter | Semibold 600 | 40 | 120% |
| H3 | Inter | Semibold 600 | 32 | 120% |
| H4 | Inter | Medium 500 | 24 | 130% |
| H5 | Inter | Medium 500 | 20 | 140% |
| Body | Inter | Regular 400 | 16 | 160% |
| Small | Inter | Regular 400 | 14 | 160% |
| Caption | Inter | Regular 400 | 12 | 160% |
| Display | Lora | Medium 500 | 40 | 125% |
| Quote | Lora | Regular 400 *italic* | 20 | 150% |

**Alignment & readability** — left aligned; generous line height (160% for body); optimal
line length 45–75 characters.

**Don't** — use too many font styles · use ALL CAPS for long text · stretch or distort type.

**Telugu.** Inter has no Telugu coverage and §14 of the scope document requires full en/te
parity on every screen, push notification and SMS. `NotoSansTelugu` is declared as the
fallback on every text style, and all three families are **bundled as assets** rather than
fetched at runtime — an NGO on a weak connection must never wait on a font download to read
a pickup window.

---

## 05. Icons

Simple, friendly, universally understandable. **2px stroke, rounded caps, 24px grid.**

**59 icons, drawn as geometry** in [`design/icons/icons.mjs`](../design/icons/icons.mjs) and
generated into Flutter, React and 74 standalone SVGs. The app needs no SVG dependency:
`SsIcon` parses the same path data the web uses, so mobile and web are the same shapes.

| Set | Count | Contents |
| --- | --- | --- |
| Core (§05.3–4) | 15 | home, search, addFood, donate, receive, map, calendar, bell, message, user, leaf, truck, package, share, settings — each with a filled variant |
| Category (§05.5) | 18 | food, fruitsVeg, bakery, meals, beverages, dairy, restaurants, cafes, grocery, events, community, impact, wasteReduction, recycle, verified, time, location, help |
| UI | 26 | check, close, chevrons, arrows, plus, minus, edit, trash, filter, more, phone, star, upload, download, info, alert, refresh, eye, eyeOff, menu, lock, logout |

The UI set is an addition, not a deviation: §06 and §07 need chevrons, a close button and a
filter glyph, and borrowing them from another icon library would break §05's own
"don't mix different styles" rule.

Sizes `16 · 20 · 24 · 32 · 48`. The 24-unit canvas scales to the requested size so the
stroke scales with it — that is what §05.6 means by "maintains visual weight".

```dart
SsIcon(SsIcons.leaf)                       // outline
SsIcon(SsIcons.home, filled: true)         // active state (§05.4)
SsIcon.named(status.iconName)              // from data
```

```tsx
<SsIcon name="leaf" />
<SsIcon name="home" filled size="lg" />
```

Preview sheet: `design/icons/preview.html`. Every icon is unit-tested to parse and to stay
inside the 24pt grid.

**Don't** — detailed icons · mixed styles · stretched or dotted forms · low contrast.

---

## 06–07. Components

Everything below ships in `packages/ss_design_system`. The Flutter widgets are the
reference implementation; the MUI theme mirrors them for the admin console.

| Section | Component | Flutter |
| --- | --- | --- |
| 06.1 | Buttons — primary, secondary, tertiary, icon | `SsButton`, `SsIconButton` |
| 06.2 | Input fields — default, focused, error, disabled | `inputDecorationTheme` |
| 06.3 | Cards | `SsDonationCard`, `cardTheme` |
| 06.4 | Badges & tags | `SsStatusBadge`, `SsTag` |
| 06.5 | Navigation — bottom (mobile), top (web) | `navigationBarTheme` |
| 06.6 | Alerts & notifications | `SsAlert` |
| 06.7 | Modals | `dialogTheme`, `bottomSheetTheme` |
| 06.8 | Dropdowns & selectors | `checkboxTheme`, `radioTheme`, `switchTheme` |
| 06.9 | Progress indicators | `progressIndicatorTheme`, `SsStepper` |
| 06.10–11 | Tooltips, pagination | `tooltipTheme` |
| 07.1–2 | Data table, list items | MUI `MuiTableCell` (admin) |
| 07.3–5 | Search & filters, tabs, accordion | `tabBarTheme` |
| 07.6–8 | Stepper, slider, date & time picker | `SsStepper`, `sliderTheme` |
| 07.9–11 | File upload, map & location, avatar | app layer |
| 07.12–14 | Empty states, success/error states, tooltip & popover | `SsEmptyState`, `SsAlert` |
| 07.15 | Selection controls | theme-level |

Product-specific additions, drawn from the scope document rather than the component pages:

- **`SsFreshnessRing`** — §02.8's time-and-freshness motif, bound to the pickup window.
  Green → orange → red as the window closes, with the minutes always spelled out.
- **`SsPickupCode`** — §12's 4-digit handover proof. This one code exchange is the entire
  proof mechanism for v1: no photo, no signature, no GPS trail.

---

## 08. Patterns & screens

Onboarding · Discovery · Request & confirmation · Status tracking · Empty states ·
Error handling · Confirmation & success · Cross-platform.

Screen sets in the PDF: Onboarding & Authentication, Browse/Search/Discovery,
Request/Pickup/Delivery, Donor Experience.

---

## 09. Illustrations

People-centric, inclusive, positive, simple and modern, consistent in style.

**40 illustrations, cropped from the design artwork itself**, with backgrounds knocked out
so each one drops cleanly onto any surface, and with the document's captions trimmed off —
the UI supplies its own heading and message, so a caption baked into the image would say
everything twice.

Two sources, both wired into `design/tools/extract_artwork.py`:

| Source | Gives | Why |
| --- | --- | --- |
| `Surplus-> Served.pdf` p18 | 39 illustrations | Captions sit *below* the artwork panel, so they crop away cleanly. |
| `design/sources/illustrations-sheet-transparent.png` | `nothingHereYet` | Already alpha-cut, and carries artwork that post-dates the PDF. |

The transparent sheet is **not** used for the other 39. Its caption pills overlap the
artwork — a horizontal cut that removes "No food available / Check back later" also takes
the leaves behind it. The PDF page keeps caption and artwork separate, so it wins for
everything it contains.

| Set | Illustrations |
| --- | --- |
| `onboarding` | onboardingWelcome, healthierPlanet, strongerCommunities, lessFoodWaste, letsGetStarted |
| `empty` | noFoodAvailable, noResultsFound, noRequestsYet, nothingHereYet |
| `role` | roleDonor, roleReceiver, roleVolunteer, roleAdmin |
| `sustainability` | goodFoodShared, reduceFoodWaste, nourishPeople, protectPlanet |
| `success` | foodReceived, requestSubmitted, deliveryCompleted, impactUnlocked |
| `progress` | progressSubmitted, progressUnderReview, progressAllocated, progressInTransit, progressCollected |
| `trust` | safeFood, foodSafety, verifiedDonor, communityTrust |
| `error` | somethingWentWrong, offline |
| `community` | realPeople, mealsThatMatter, todaysSurplus, togetherCommunities, cleanerPlanet, smallActionsBigImpact |
| `promo` / `brand` | appPromotion, leafMotif |

```dart
SsIllustration(SsIllustrations.noFoodAvailable, width: 160)

SsEmptyState(
  title: 'No food nearby',
  message: "We couldn't find any food near your location right now.",
  illustration: SsIllustrations.noFoodAvailable,
)
```

```tsx
<SsIllustration name="noFoodAvailable" width={160} />
```

### Resolution ceiling — read before using these at size

The design document is a **flattened raster**: every page is one JPEG, so the artwork cannot
be extracted as vectors. Page 18 is 1223px wide, which makes an individual illustration
**80–190px across**. That is comfortable at the sizes the product uses them (an empty-state
spot at 120–170px) and visibly soft if blown up.

Both `SsIllustration` implementations carry the native size and warn in debug builds when a
caller asks for more than roughly 1.75× it. When the designer's original exports arrive,
drop them in over the same filenames in `design/assets/` and re-run
`node design/tools/generate-artwork.mjs` — no calling code changes.

Re-cropping (only needed if a source changes):

```bash
pip install pypdf pillow numpy
python3 design/tools/extract_artwork.py
node design/tools/generate-artwork.mjs
```

Rule from §11: **show real people and diverse communities; never show waste or unsafe food.**

---

## 10. Accessibility

Target: **WCAG 2.2 AA**, with ADA, EN 301 549 and Section 508 as secondary references.

| Area | Commitment |
| --- | --- |
| Contrast | ≥ 4.5:1 body text, ≥ 3:1 large text and non-text |
| Text scaling | Up to 200% without loss of function |
| Tap targets | Minimum 44 × 44 px |
| Keyboard | Logical tab order, visible focus, skip-to-content |
| Screen readers | Semantic markup, ARIA labels, meaningful alt text; tested on VoiceOver, TalkBack, NVDA |
| Colour | Meaning is never conveyed by colour alone |
| Motion | `prefers-reduced-motion` respected |
| Language | English and Telugu at full parity |

Every component in this repo carries its own `Semantics` node. `SsStatusBadge` renders an
icon and a label beside the colour; `SsIconButton` requires a `tooltip` that doubles as its
screen-reader label; `SsFreshnessRing` announces "Pickup window: 18 min left".

Contrast is verified in CI, **in both themes**:

```bash
node design/tools/check-contrast.mjs   # 34 pairings
```

The dark-mode gate is not decorative. Dark tints a status chip with the status
hue rather than using the pale light-mode surface, so the light pair proves
nothing about it — and eight of the ten badges failed AA on dark until each
status gained a verified `dark` tone. `SsStatus` therefore carries three
colours: `color` (the brand hue, for fills), `text` (AA on the light surface)
and `dark` (AA on the tinted dark chip).

---

## 11. Guidelines

User-centred · Consistency · Clarity & simplicity · Trust & transparency ·
Inclusivity & accessibility · Safety first · Error handling · Performance & reliability ·
Content guidelines · Data privacy & security · Sustainability & impact · Continuous improvement.

**Content — do:** positive and respectful tone · clear and concise · inclusive and neutral
language · real people and diverse communities · focus on impact and solutions.

**Content — don't:** negative or fear-based language · unrealistic promises · slang or
unclear terms · waste or unsafe food imagery · exclude any community or group.

---

## 12. Resources

Design assets (Figma UI kit, SVG, PNG), templates, component library, icon library,
illustrations, guidelines, case studies, learning material, developer resources, brand kit.

In this repo the developer half of that list is real today:

- `design/tokens/tokens.json` — token source
- `design/tools/generate.mjs` — generator
- `packages/ss_design_system` — Flutter theme + components
- `packages/web-ui` — MUI theme + CSS variables

---

## 13. Deviations from the PDF

Three places where I did not copy the document verbatim. Each is a correction, not a
redesign, and each is reversible in `tokens.json`.

### 1. Display font — Poppins vs Lora

Page 01 lists the display font as **Poppins**; page 04, the dedicated typography page,
lists the secondary typeface as **Lora** with a full specimen, a rationale, and a
"Inter + Lora" pairing block. I took page 04 as authoritative and used **Lora**.
If Poppins was the intent, change `typography.family.secondary` and the two Lora entries
in `typography.scale`, then regenerate.

### 2. AA-safe text tones on tinted containers

The PDF pairs saturated semantic hues with their own pale tints (e.g. `success #16A34A`
label on `#E6F3EC`). Measured, several of those pairs fail the AA body-text floor the same
document commits to on page 10:

| Pair | Measured | Required |
| --- | --- | --- |
| `#16A34A` on `#E6F3EC` | 2.89:1 | 4.5:1 |
| `#D97706` on `#FDF3E2` | 2.90:1 | 4.5:1 |
| `#DC2626` on `#FDECEA` | 4.22:1 | 4.5:1 |
| `#FFFFFF` on `#E39A1F` | 2.36:1 | 4.5:1 |

Rather than change the brand hues, I added an `onContainer` / `text` tone per semantic and
per status — the same hue darkened until it passes — and reserved the original hue for
fills, dots and gradients where only the 3:1 non-text floor applies. Harvest Orange buttons
use `ink` for their label (7.04:1), not white.

Disabled text (`muted` on `surface`, 2.15:1) is left as designed: WCAG 1.4.3 exempts
disabled controls, and the PDF's own accessibility page shows that pair as the "does not
pass" example deliberately.

### 3. Spacing, radius, elevation and motion scales

The PDF specifies no spacing, corner-radius, shadow or motion values. I derived a 4pt
spacing scale, a 4/8/12/16/24/pill radius scale, a five-step shadow ramp and a five-step
motion ramp that match the proportions visible in the mockups. These are the only fully
invented tokens in the system — everything else is transcribed.

### 4. A UI icon set alongside the document's two

§05 covers brand and category icons. The components in §06 and §07 also need chevrons, a
close button, a filter glyph, a phone, a star and so on. Rather than pull those from another
icon library — which would break §05's own "don't mix different styles" rule — they are drawn
to the same 24pt grid and 2px stroke and shipped as a third `ui` set.

### 5. Illustrations and the logo are raster crops, not vectors

The design document is a flattened raster, so §09's artwork and §02's logo could only be
recovered by cropping. They are the document's real artwork, background-removed, at the
document's own resolution — see the ceiling noted in [§09](#09-illustrations).

---

## 14. Coverage

| § | Section | State |
| --- | --- | --- |
| 01 | Introduction | Documented |
| 02 | Brand | Complete — voice, principles, logo assets and rules in code |
| 03 | Colors | Complete — tokens, both themes, AA gate in CI |
| 04 | Typography | Complete — scale, both families bundled, Telugu fallback |
| 05 | Icons | Complete — 59 icons, outline + filled, Flutter and React |
| 06 | Components | Complete — 23 themed Material widgets + 20 `Ss*` components |
| 07 | Components pt. 2 | Complete — data table, list items, filters, accordion, stepper, date/time, upload, avatar, empty/success/error states, pagination |
| 08 | Screens | **Not built** — excluded by request; this is app-layer work |
| 09 | Illustrations | Complete — 39 illustrations from the document |
| 10 | Accessibility | Complete — enforced in components, gated in CI |
| 11 | Guidelines | Documented |
| 12 | Resources | Developer half is real; Figma/Sketch libraries are a designer deliverable |

Component inventory:

**Flutter — every §06 and §07 item:**

| §06 | §07 |
| --- | --- |
| 1 Buttons — `SsButton`, `SsIconButton` | 1 Data table — `SsDataTable`, `SsColumn` |
| 2 Inputs — `SsTextField` | 2 List items — `SsListTile` |
| 3 Cards — `SsDonationCard`, `SsStatCard` | 3 Search & filters — `SsSearchField`, `SsFilterBar`, `SsFilterDropdownChip`, `SsFilterChips` |
| 4 Badges & tags — `SsStatusBadge`, `SsTag` | 4 Tabs — `SsTabs`, `SsSegmentedTabs` |
| 5 Navigation — `SsBottomNav`, `SsTopNav` | 5 Accordion — `SsAccordion` |
| 6 Alerts — `SsAlert`, `SsToast` | 6 Stepper — `SsStepper` |
| 7 Modals — `SsDialog`, `SsSheet` | 7 Slider — `SsSlider` |
| 8 Dropdowns & selectors — `SsDropdown`, `SsCheckbox`, `SsRadioGroup`, `SsSwitch` | 8 Date & time — `SsDateTimeField` |
| 9 Progress — `SsProgressBar`, `SsStepper` | 9 File upload — `SsFileUpload` |
| 10 Tooltips — `tooltipTheme` | 10 Map & location — `SsMapCard`, `SsLocationRow` |
| 11 Pagination — `SsPagination` | 11 Avatar — `SsAvatar` |
| | 12 Empty states — `SsEmptyState` |
| | 13 Success / error — `SsAlert` |
| | 14 Tooltip & popover — `SsNotificationTile` |
| | 15 Selection controls — `SsCheckbox`, `SsRadioGroup`, `SsSwitch` |

Plus the product-specific pieces: `SsFreshnessRing` (§02.8), `SsPickupCode` (scope §12),
`SsIcon`, `SsIllustration`, `SsLogo`, `SsLogoLockup`.

**React (MUI)** — `StatusChip`, `Tag`, `EmptyState`, `StatCard`, `DataTable`,
`FreshnessRing`, `PageHeader`, `ConfirmDialog`, `FilterBar`, `SsIcon`, `SsIllustration`,
`Logo`. The admin console's form primitives — select, checkbox, radio, switch, slider,
tabs — are MUI's own, styled by `theme.ts`, so they are not duplicated here.

Both platforms have somewhere to *look* at every component rather than trusting that it
compiles:

```bash
cd packages/ss_design_system && flutter test --update-goldens test/golden
#   -> test/golden/goldens/*.png, six sheets covering every component

npm --workspace @surplus-served/web-ui run demo
#   -> http://localhost:4173, with a light/dark toggle
```

The web gallery earned its keep immediately: it caught `Logo` and `SsIllustration` missing
from the package barrel, the status chips and tags pinned to light-theme surfaces, and the
wordmark vanishing on dark. `src/barrel.check.ts` now fails the typecheck if a public export
is dropped again.

---

## 15. What is still missing

Two things a designer still owes, which I have deliberately not faked:

1. **Higher-resolution artwork.** The illustrations and logo are 80–255px crops because that
   is all the flattened PDF contains. Ask whoever produced the document for the original
   exports; drop them in over the same filenames and re-run the generator.
2. **The Figma / Sketch libraries** listed in §12. The token JSON is the machine-readable
   source those should be built from, not the other way round.

---

## 16. Scope note

The design system PDF shows a **Volunteer** role, in-app chat, live delivery navigation and
in-transit tracking. The scope document (§3, §17) explicitly rules all four out of v1:
three roles only (Donor, Receiver, Admin), tap-to-call instead of chat, self-collect with no
delivery leg, and therefore no in-transit state.

The tokens and components here are complete and role-agnostic, so nothing needs rebuilding
when those features arrive. But the v1 app should not ship the Volunteer role, the chat
screen, or the live-navigation screen. `SsStatus` intentionally models the scope document's
state machine — `draft → pendingCheck → live → allocated → collected`, plus `reallocated`,
`unfulfilled`, `cancelled`, `rejected` — and has no in-transit member.

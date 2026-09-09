#!/usr/bin/env python3
"""
Surplus → Served — artwork extraction (§02 logo, §09 illustrations).

    python3 design/tools/extract_artwork.py

Crops the illustrations and the logo out of the design document and writes them
as trimmed, background-free PNGs plus a manifest that the code generators read.

    design/assets/illustrations/*.png
    design/assets/brand/*.png
    design/assets/manifest.json

WHY THIS EXISTS
    The design PDF is a flattened raster — every page is a single JPEG, so the
    artwork cannot be pulled out as vectors. These crops are the real artwork
    from the document, at the only resolution the document contains.

RESOLUTION CEILING
    Page 18 (Illustrations) is 1223 px wide, so an individual illustration is
    roughly 80–190 px across. That is fine at small sizes and soft when blown
    up. `maxSensibleWidth` in the manifest records the native width so the UI
    layer can avoid over-scaling. For crisp assets, get the original export
    from whoever produced the document and drop it in over the top — the names
    and the manifest stay the same.

DEPENDENCIES
    pip install pypdf pillow numpy
"""

from __future__ import annotations

import json
import os
import sys
from collections import deque
from pathlib import Path

try:
    import numpy as np
    from PIL import Image
    from pypdf import PdfReader
except ImportError as exc:  # pragma: no cover - operator-facing message
    sys.exit(f"Missing dependency: {exc}. Run: pip install pypdf pillow numpy")

ROOT = Path(__file__).resolve().parents[2]
PDF = ROOT / "Surplus-> Served.pdf"
OUT = ROOT / "design" / "assets"

# A second, alpha-transparent export of the §09 sheet. It carries illustrations
# that post-date the PDF. Most of its artwork is NOT re-cropped from here: the
# caption pills on that sheet overlap the illustrations, so a clean cut would
# take part of the artwork with it. See the note in docs/DESIGN_SYSTEM.md §09.
TRANSPARENT_SHEET = ROOT / "design" / "sources" / "illustrations-sheet-transparent.png"

# Page index (1-based, as the PDF numbers them) -> extracted page raster.
ILLUSTRATION_PAGE = 18
BRAND_PAGE = 2

# ---------------------------------------------------------------------------
# Crop map. Boxes are (left, top, right, bottom) in the page raster's own
# pixels, taken from the tinted artwork panels. Explicit rather than
# auto-detected so the output is byte-stable across runs.
# ---------------------------------------------------------------------------

ILLUSTRATIONS = [
    # name,                  box,                        set,              caption
    ("onboardingWelcome",    (180, 297, 309, 429),  "onboarding",     "Welcome to a kinder tomorrow"),
    ("healthierPlanet",      (315, 297, 426, 426),  "onboarding",     "A healthier planet"),
    ("strongerCommunities",  (429, 297, 549, 420),  "onboarding",     "Stronger communities"),
    ("lessFoodWaste",        (555, 297, 669, 423),  "onboarding",     "Less food waste"),
    ("letsGetStarted",       (678, 297, 777, 429),  "onboarding",     "Let's get started"),

    ("noFoodAvailable",      (804, 297, 927, 405),  "empty",          "No food available — check back later"),
    ("noResultsFound",       (939, 297, 1062, 402), "empty",          "No results found — try a different location or search"),
    ("noRequestsYet",        (1077, 297, 1197, 402),"empty",          "No requests yet — be the first to request"),

    ("roleDonor",            (180, 501, 312, 633),  "role",           "I'm a donor — share surplus food"),
    ("roleReceiver",         (324, 504, 453, 630),  "role",           "I'm a receiver — get food support"),
    ("roleVolunteer",        (462, 504, 597, 633),  "role",           "I'm a volunteer — deliver hope"),
    ("roleAdmin",            (600, 504, 729, 630),  "role",           "I'm an admin — manage and monitor"),

    ("goodFoodShared",       (756, 507, 861, 633),  "sustainability", "Good food should be shared"),
    ("reduceFoodWaste",      (867, 507, 969, 633),  "sustainability", "Reduce food waste"),
    ("nourishPeople",        (978, 507, 1080, 630), "sustainability", "Nourish people"),
    ("protectPlanet",        (1086, 507, 1197, 633),"sustainability", "Protect our planet"),

    ("foodReceived",         (36, 723, 165, 813),   "success",        "Food received — thank you!"),
    ("requestSubmitted",     (180, 726, 312, 810),  "success",        "Request submitted — we'll keep you updated"),
    ("deliveryCompleted",    (324, 723, 450, 813),  "success",        "Delivery completed — great job!"),
    ("impactUnlocked",       (462, 723, 600, 810),  "success",        "Impact unlocked — you're making a difference"),

    ("progressSubmitted",    (639, 738, 720, 816),  "progress",       "Submitted"),
    ("progressUnderReview",  (753, 735, 831, 816),  "progress",       "Under review"),
    ("progressAllocated",    (861, 735, 942, 816),  "progress",       "Allocated"),
    ("progressInTransit",    (981, 738, 1059, 813), "progress",       "In transit"),
    ("progressCollected",    (1095, 735, 1182, 816),"progress",       "Collected"),

    ("safeFood",             (33, 900, 153, 984),  "trust",          "Safe food, healthy people"),
    ("foodSafety",           (162, 900, 279, 987), "trust",          "Food safety matters"),
    ("verifiedDonor",        (291, 900, 411, 999),  "trust",          "Verified donor, trusted food"),
    ("communityTrust",       (420, 900, 543, 981), "trust",          "Community you can trust"),

    ("somethingWentWrong",   (576, 903, 735, 999),  "error",          "Something went wrong — please try again"),
    ("offline",              (747, 903, 903, 990), "error",          "You're offline — check your connection"),

    ("appPromotion",         (936, 903, 1058, 1044),"promo",          "Download the app — be part of the change"),

    ("realPeople",           (30, 1089, 198, 1176), "community",      "Real people. Real change."),
    ("mealsThatMatter",      (207, 1089, 387, 1173),"community",      "Meals that matter"),
    ("todaysSurplus",        (402, 1089, 591, 1173),"community",      "Today's surplus. Tomorrow's hope."),
    ("togetherCommunities",  (603, 1089, 792, 1167),"community",      "Together for stronger communities"),
    ("cleanerPlanet",        (807, 1089, 990, 1176),"community",      "A cleaner, greener planet"),
    ("smallActionsBigImpact",(1002, 1086, 1194, 1191),"community",    "Small actions. Big impact."),

    ("leafMotif",            (18, 537, 69, 606),    "brand",          "Leaf motif"),
]

# (name, box, set, caption) — cropped from TRANSPARENT_SHEET.
EXTRA_ILLUSTRATIONS = [
    ("nothingHereYet", (1362, 326, 1500, 448), "empty",
     "Nothing here yet — good things come soon"),
]

BRAND = [
    ("logoHorizontal", (186, 345, 441, 399), "Surplus → Served — primary horizontal logo"),
    ("logoStacked",    (480, 312, 606, 441), "Surplus → Served — stacked logo"),
    ("logoIcon",       (636, 339, 723, 423), "Surplus → Served — icon only"),
    ("leafMark",       (138, 1059, 234, 1155), "Leaf mark"),
    ("movementArrow",  (30, 1059, 126, 1155),  "Movement thread — the arrow that shows food in motion"),
]


# ---------------------------------------------------------------------------


def page_rasters(pdf_path: Path) -> dict[int, Image.Image]:
    """Every page of the design PDF is one flattened JPEG; pull them all out."""
    reader = PdfReader(str(pdf_path))
    pages: dict[int, Image.Image] = {}
    for index, page in enumerate(reader.pages, start=1):
        images = list(page.images)
        if images:
            import io

            pages[index] = Image.open(io.BytesIO(images[0].data)).convert("RGB")
    return pages


def knock_out_background(im: Image.Image, tolerance: int = 26, feather: int = 1) -> Image.Image:
    """Make the tinted panel behind the artwork transparent.

    Flood-fills inward from the border only, so light areas *inside* the
    artwork (a white shirt, a pale sky) are never punched through.
    """
    rgb = im.convert("RGB")
    a = np.asarray(rgb).astype(int)
    h, w, _ = a.shape

    corners = np.concatenate(
        [a[0, :].reshape(-1, 3), a[-1, :].reshape(-1, 3),
         a[:, 0].reshape(-1, 3), a[:, -1].reshape(-1, 3)]
    )
    bg = np.median(corners, axis=0)

    close = np.abs(a - bg).sum(axis=2) <= tolerance

    transparent = np.zeros((h, w), dtype=bool)
    q: deque[tuple[int, int]] = deque()
    for x in range(w):
        for y in (0, h - 1):
            if close[y, x] and not transparent[y, x]:
                transparent[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if close[y, x] and not transparent[y, x]:
                transparent[y, x] = True
                q.append((y, x))

    while q:
        cy, cx = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and close[ny, nx] and not transparent[ny, nx]:
                transparent[ny, nx] = True
                q.append((ny, nx))

    alpha = np.where(transparent, 0, 255).astype(np.uint8)

    if feather:
        # Soften the cut edge so the artwork does not look stencilled.
        af = alpha.astype(np.float64)
        pad = np.pad(af, feather, mode="edge")
        acc = np.zeros_like(af)
        n = 0
        for dy in range(2 * feather + 1):
            for dx in range(2 * feather + 1):
                acc += pad[dy:dy + h, dx:dx + w]
                n += 1
        alpha = (acc / n).astype(np.uint8)

    out = rgb.convert("RGBA")
    out.putalpha(Image.fromarray(alpha, mode="L"))
    return out


def trim_transparent(im: Image.Image, pad: int = 2) -> Image.Image:
    """Trim fully transparent margins so each asset is tight to its artwork."""
    a = np.asarray(im)
    if a.shape[2] < 4:
        return im
    solid = a[:, :, 3] > 8
    rows = np.where(solid.any(axis=1))[0]
    cols = np.where(solid.any(axis=0))[0]
    if len(rows) == 0 or len(cols) == 0:
        return im
    h, w = solid.shape
    return im.crop(
        (
            max(0, cols[0] - pad),
            max(0, rows[0] - pad),
            min(w, cols[-1] + 1 + pad),
            min(h, rows[-1] + 1 + pad),
        )
    )


def main() -> None:
    if not PDF.exists():
        sys.exit(f"Cannot find the design document at {PDF}")

    pages = page_rasters(PDF)
    illo_page = pages[ILLUSTRATION_PAGE]
    brand_page = pages[BRAND_PAGE]

    illo_dir = OUT / "illustrations"
    brand_dir = OUT / "brand"
    for d in (illo_dir, brand_dir):
        d.mkdir(parents=True, exist_ok=True)
        for f in d.glob("*.png"):
            f.unlink()

    manifest: dict[str, list] = {"illustrations": [], "brand": []}

    for name, box, group, caption in ILLUSTRATIONS:
        art = trim_transparent(knock_out_background(illo_page.crop(box)))
        art.save(illo_dir / f"{name}.png", optimize=True)
        manifest["illustrations"].append(
            {
                "name": name,
                "set": group,
                "caption": caption,
                "asset": f"assets/illustrations/{name}.png",
                "width": art.width,
                "height": art.height,
            }
        )
        print(f"  illustration  {name:24} {art.width}×{art.height}")

    if TRANSPARENT_SHEET.exists():
        sheet = Image.open(TRANSPARENT_SHEET).convert("RGBA")
        for name, box, group, caption in EXTRA_ILLUSTRATIONS:
            # Already alpha-cut at source, so it only needs trimming.
            art = trim_transparent(sheet.crop(box))
            art.save(illo_dir / f"{name}.png", optimize=True)
            manifest["illustrations"].append(
                {
                    "name": name,
                    "set": group,
                    "caption": caption,
                    "asset": f"assets/illustrations/{name}.png",
                    "width": art.width,
                    "height": art.height,
                }
            )
            print(f"  illustration  {name:24} {art.width}×{art.height}  (transparent sheet)")
    else:
        print(f"  ! {TRANSPARENT_SHEET.name} not found — skipping extra illustrations")

    for name, box, caption in BRAND:
        art = trim_transparent(knock_out_background(brand_page.crop(box)))
        art.save(brand_dir / f"{name}.png", optimize=True)
        manifest["brand"].append(
            {
                "name": name,
                "caption": caption,
                "asset": f"assets/brand/{name}.png",
                "width": art.width,
                "height": art.height,
            }
        )
        print(f"  brand         {name:24} {art.width}×{art.height}")

    manifest["illustrations"].sort(key=lambda i: i["name"])

    manifest["source"] = {
        "document": PDF.name,
        "transparentSheet": TRANSPARENT_SHEET.name,
        "illustrationPage": ILLUSTRATION_PAGE,
        "brandPage": BRAND_PAGE,
        "note": (
            "Cropped from the flattened design PDF. Native resolution is the "
            "ceiling — see the header of design/tools/extract_artwork.py."
        ),
    }

    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(
        f"\n  {len(manifest['illustrations'])} illustrations, "
        f"{len(manifest['brand'])} brand assets → design/assets/\n"
    )


if __name__ == "__main__":
    main()

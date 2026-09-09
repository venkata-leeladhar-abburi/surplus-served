/**
 * Path primitives for the Surplus → Served icon set.
 *
 * Everything here emits ONLY `M`, `L`, `C` and `Z` in absolute coordinates.
 * That restriction is deliberate: the Flutter renderer parses this subset
 * directly (`SsIconPath.parse`), so the app needs no SVG dependency and the
 * web and mobile icons are guaranteed to be the same geometry.
 *
 * Canvas is a 24 × 24 grid with a 2px safe margin — draw inside 2 … 22.
 */

/** Cubic approximation constant for a quarter circle. */
const K = 0.5522847498307936;

const n = (v) => {
  const r = Math.round(v * 1000) / 1000;
  return Object.is(r, -0) ? 0 : r;
};

const pt = (x, y) => `${n(x)} ${n(y)}`;

/** Move to. */
export const M = (x, y) => `M${pt(x, y)}`;

/** Line to. */
export const L = (x, y) => `L${pt(x, y)}`;

/** Cubic bézier. */
export const C = (x1, y1, x2, y2, x, y) =>
  `C${pt(x1, y1)} ${pt(x2, y2)} ${pt(x, y)}`;

/** Close path. */
export const Z = 'Z';

/** Join path commands into one subpath string. */
export const path = (...parts) => parts.flat().join('');

/** A full circle, drawn clockwise from 12 o'clock. */
export const circle = (cx, cy, r) => {
  const k = r * K;
  return path(
    M(cx, cy - r),
    C(cx + k, cy - r, cx + r, cy - k, cx + r, cy),
    C(cx + r, cy + k, cx + k, cy + r, cx, cy + r),
    C(cx - k, cy + r, cx - r, cy + k, cx - r, cy),
    C(cx - r, cy - k, cx - k, cy - r, cx, cy - r),
    Z,
  );
};

/** An ellipse, same winding as [circle]. */
export const ellipse = (cx, cy, rx, ry) => {
  const kx = rx * K;
  const ky = ry * K;
  return path(
    M(cx, cy - ry),
    C(cx + kx, cy - ry, cx + rx, cy - ky, cx + rx, cy),
    C(cx + rx, cy + ky, cx + kx, cy + ry, cx, cy + ry),
    C(cx - kx, cy + ry, cx - rx, cy + ky, cx - rx, cy),
    C(cx - rx, cy - ky, cx - kx, cy - ry, cx, cy - ry),
    Z,
  );
};

/**
 * An open arc, angles in degrees, 0° at 3 o'clock, increasing clockwise
 * (screen coordinates — y grows downward).
 */
export const arc = (cx, cy, r, a0, a1, { move = true } = {}) => {
  const rad = (d) => (d * Math.PI) / 180;
  const total = a1 - a0;
  const steps = Math.max(1, Math.ceil(Math.abs(total) / 90));
  const step = total / steps;
  const parts = [];

  let a = a0;
  if (move) parts.push(M(cx + r * Math.cos(rad(a)), cy + r * Math.sin(rad(a))));

  for (let i = 0; i < steps; i++) {
    const b = a + step;
    const k = (4 / 3) * Math.tan(rad(step) / 4) * r;
    const [ca, sa] = [Math.cos(rad(a)), Math.sin(rad(a))];
    const [cb, sb] = [Math.cos(rad(b)), Math.sin(rad(b))];
    parts.push(
      C(
        cx + r * ca - k * sa,
        cy + r * sa + k * ca,
        cx + r * cb + k * sb,
        cy + r * sb - k * cb,
        cx + r * cb,
        cy + r * sb,
      ),
    );
    a = b;
  }
  return path(parts);
};

/** A rounded rectangle. `r` may be a number or [tl, tr, br, bl]. */
export const rrect = (x, y, w, h, r = 0) => {
  const [tl, tr, br, bl] = Array.isArray(r) ? r : [r, r, r, r];
  const k = (v) => v * (1 - K);
  return path(
    M(x + tl, y),
    L(x + w - tr, y),
    tr ? C(x + w - k(tr), y, x + w, y + k(tr), x + w, y + tr) : '',
    L(x + w, y + h - br),
    br ? C(x + w, y + h - k(br), x + w - k(br), y + h, x + w - br, y + h) : '',
    L(x + bl, y + h),
    bl ? C(x + k(bl), y + h, x, y + h - k(bl), x, y + h - bl) : '',
    L(x, y + tl),
    tl ? C(x, y + k(tl), x + k(tl), y, x + tl, y) : '',
    Z,
  );
};

/** A polyline through `points`; set `close` to finish the shape. */
export const poly = (points, close = false) =>
  path(
    M(...points[0]),
    points.slice(1).map(([x, y]) => L(x, y)),
    close ? Z : '',
  );

/** A single straight segment. */
export const line = (x1, y1, x2, y2) => path(M(x1, y1), L(x2, y2));

/**
 * The leaf motif (§02.8) — the shape the whole brand is built on.
 * Two mirrored quadrant-ish curves meeting at tip and base.
 */
export const leafShape = (cx, cy, w, h, tilt = 0) => {
  const hw = w / 2;
  const hh = h / 2;
  const rot = (x, y) => {
    const a = (tilt * Math.PI) / 180;
    const dx = x - cx;
    const dy = y - cy;
    return [cx + dx * Math.cos(a) - dy * Math.sin(a), cy + dx * Math.sin(a) + dy * Math.cos(a)];
  };
  const tip = rot(cx, cy - hh);
  const base = rot(cx, cy + hh);
  // Controls sit outside the half-width: a cubic only reaches ~75% of the way
  // to its control points, so pushing them out is what gives the leaf its belly.
  const rc1 = rot(cx + hw * 1.22, cy - hh * 0.5);
  const rc2 = rot(cx + hw * 1.16, cy + hh * 0.52);
  const lc1 = rot(cx - hw * 1.16, cy + hh * 0.52);
  const lc2 = rot(cx - hw * 1.22, cy - hh * 0.5);
  return path(
    M(...tip),
    C(...rc1, ...rc2, ...base),
    C(...lc1, ...lc2, ...tip),
    Z,
  );
};

/** The leaf's central vein, matched to [leafShape]. */
export const leafVein = (cx, cy, h, tilt = 0) => {
  const hh = h / 2;
  const rot = (x, y) => {
    const a = (tilt * Math.PI) / 180;
    const dx = x - cx;
    const dy = y - cy;
    return [cx + dx * Math.cos(a) - dy * Math.sin(a), cy + dx * Math.sin(a) + dy * Math.cos(a)];
  };
  // Stops short of the tip: a full-length centre line turns the symmetric
  // almond into a "Ø" once the icon drops to 16px.
  return path(M(...rot(cx, cy - hh * 0.18)), L(...rot(cx, cy + hh * 0.92)));
};

/** A gear outline with `teeth` square-ish teeth between two radii. */
export const gear = (cx, cy, rOuter, rInner, teeth = 8, duty = 0.42) => {
  const step = 360 / teeth;
  const half = step * duty;
  const rad = (d) => (d * Math.PI) / 180;
  const at = (r, a) => [cx + r * Math.cos(rad(a)), cy + r * Math.sin(rad(a))];

  const parts = [];
  for (let i = 0; i < teeth; i++) {
    const a = i * step;
    const t0 = a - half / 2;
    const t1 = a + half / 2;
    const v0 = t1;
    const v1 = t0 + step;

    if (i === 0) parts.push(M(...at(rOuter, t0)));
    else parts.push(L(...at(rOuter, t0)));

    parts.push(arc(cx, cy, rOuter, t0, t1, { move: false }));
    parts.push(L(...at(rInner, v0)));
    parts.push(arc(cx, cy, rInner, v0, v1, { move: false }));
  }
  parts.push(Z);
  return path(parts);
};

/**
 * A chevron arrowhead sitting on a circle at `angleDeg`, pointing along the
 * tangent. Pairs with [arc] to build circular-arrow icons.
 */
export const arrowHead = (cx, cy, r, angleDeg, size = 2.8, sweep = 'cw') => {
  const a = (angleDeg * Math.PI) / 180;
  const px = cx + r * Math.cos(a);
  const py = cy + r * Math.sin(a);
  const s = sweep === 'cw' ? 1 : -1;
  const tx = -Math.sin(a) * s;
  const ty = Math.cos(a) * s;
  const rx = Math.cos(a);
  const ry = Math.sin(a);
  const back = size * 0.95;
  const spread = size * 0.72;
  return poly([
    [px - tx * back + rx * spread, py - ty * back + ry * spread],
    [px, py],
    [px - tx * back - rx * spread, py - ty * back - ry * spread],
  ]);
};

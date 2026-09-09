/**
 * Surplus → Served icon set (§05).
 *
 * 15 core icons with outline + filled variants, 18 category icons in outline.
 * That split mirrors the design document exactly: §05.3 shows the core set,
 * §05.4 shows filled variants of the same fifteen, §05.5 shows the categories.
 *
 * House style, from §05.2:
 *   · 24 × 24 grid, content inside 2 … 22
 *   · 2px stroke, round caps, round joins
 *   · consistent corner radius, no detail that dies below 20px
 *
 * `outline` paths are STROKED. `filled` paths are FILLED with the even-odd
 * rule, so an inner shape drawn over an outer one becomes a hole — unless the
 * icon declares `fillRule: 'nonzero'`, which unions overlapping shapes instead.
 */

import {
  M, L, C, Z,
  arc, arrowHead, circle, ellipse, gear, leafShape, leafVein, line, path, poly, rrect,
} from './geom.mjs';

/* ────────────────────────────────────────────────────────────────────────
   Core — §05.3 / §05.4
   ──────────────────────────────────────────────────────────────────────── */

const core = {
  home: {
    keywords: ['house', 'feed', 'start'],
    outline: [
      poly([[3.2, 11.2], [12, 3.8], [20.8, 11.2]]),
      poly([[5.9, 9.9], [5.9, 20.2], [18.1, 20.2], [18.1, 9.9]]),
      poly([[9.7, 20.2], [9.7, 14.4], [14.3, 14.4], [14.3, 20.2]]),
    ],
    filled: [
      poly(
        [[12, 3], [2.2, 11.3], [4.9, 11.3], [4.9, 20.8], [9.7, 20.8],
         [9.7, 14.6], [14.3, 14.6], [14.3, 20.8], [19.1, 20.8],
         [19.1, 11.3], [21.8, 11.3]],
        true,
      ),
    ],
  },

  search: {
    keywords: ['find', 'magnifier', 'discover'],
    outline: [circle(10.6, 10.6, 6.6), line(15.3, 15.3, 20.6, 20.6)],
    fillRule: 'nonzero',
    filled: [
      circle(10.6, 10.6, 6.9),
      poly([[15.4, 14.0], [21.0, 19.6], [19.6, 21.0], [14.0, 15.4]], true),
    ],
  },

  addFood: {
    keywords: ['add', 'plus', 'donate food', 'create listing'],
    outline: [circle(12, 12, 8.6), line(12, 8.1, 12, 15.9), line(8.1, 12, 15.9, 12)],
    filled: [
      circle(12, 12, 9),
      poly(
        [[10.9, 7.3], [13.1, 7.3], [13.1, 10.9], [16.7, 10.9], [16.7, 13.1],
         [13.1, 13.1], [13.1, 16.7], [10.9, 16.7], [10.9, 13.1],
         [7.3, 13.1], [7.3, 10.9], [10.9, 10.9]],
        true,
      ),
    ],
  },

  donate: {
    keywords: ['heart', 'give', 'favourite', 'love'],
    outline: [
      path(
        M(12, 20.6),
        C(12, 20.6, 3.4, 15.6, 3.4, 9.5),
        C(3.4, 6.6, 5.7, 4.3, 8.5, 4.3),
        C(10.2, 4.3, 11.4, 5.2, 12, 6.4),
        C(12.6, 5.2, 13.8, 4.3, 15.5, 4.3),
        C(18.3, 4.3, 20.6, 6.6, 20.6, 9.5),
        C(20.6, 15.6, 12, 20.6, 12, 20.6),
        Z,
      ),
    ],
    filled: [
      path(
        M(12, 21),
        C(12, 21, 3, 15.8, 3, 9.4),
        C(3, 6.3, 5.4, 3.9, 8.4, 3.9),
        C(10.2, 3.9, 11.4, 4.8, 12, 6.1),
        C(12.6, 4.8, 13.8, 3.9, 15.6, 3.9),
        C(18.6, 3.9, 21, 6.3, 21, 9.4),
        C(21, 15.8, 12, 21, 12, 21),
        Z,
      ),
    ],
  },

  receive: {
    keywords: ['inbox', 'collect', 'incoming', 'accept'],
    outline: [
      rrect(3.4, 10.2, 17.2, 10.4, 2.4),
      line(12, 3.2, 12, 8.6),
      poly([[8.9, 5.6], [12, 8.7], [15.1, 5.6]]),
    ],
    fillRule: 'nonzero',
    filled: [
      rrect(3.4, 10.2, 17.2, 10.4, 2.4),
      poly(
        [[10.9, 3.2], [13.1, 3.2], [13.1, 5.9], [15.8, 5.9], [12, 9.7],
         [8.2, 5.9], [10.9, 5.9]],
        true,
      ),
    ],
  },

  map: {
    keywords: ['pin', 'location', 'nearby', 'place'],
    outline: [
      path(
        M(12, 21.2),
        C(12, 21.2, 18.9, 15.2, 18.9, 10.3),
        C(18.9, 6.5, 15.8, 3.4, 12, 3.4),
        C(8.2, 3.4, 5.1, 6.5, 5.1, 10.3),
        C(5.1, 15.2, 12, 21.2, 12, 21.2),
        Z,
      ),
      circle(12, 10.1, 2.6),
    ],
    filled: [
      path(
        M(12, 21.6),
        C(12, 21.6, 19.3, 15.3, 19.3, 10.2),
        C(19.3, 6.2, 16.1, 3, 12, 3),
        C(7.9, 3, 4.7, 6.2, 4.7, 10.2),
        C(4.7, 15.3, 12, 21.6, 12, 21.6),
        Z,
      ),
      circle(12, 10.1, 2.5),
    ],
  },

  calendar: {
    keywords: ['date', 'schedule', 'pickup window'],
    outline: [
      rrect(3.4, 5.6, 17.2, 15, 2.4),
      line(3.4, 10.2, 20.6, 10.2),
      line(8, 3.2, 8, 7.2),
      line(16, 3.2, 16, 7.2),
    ],
    filled: [
      rrect(3.4, 5.6, 17.2, 15, 2.4),
      rrect(6.9, 2.4, 2.2, 3.2, 1.1),
      rrect(14.9, 2.4, 2.2, 3.2, 1.1),
      circle(8.6, 14.6, 1.2),
      circle(12, 14.6, 1.2),
      circle(15.4, 14.6, 1.2),
    ],
  },

  bell: {
    keywords: ['notification', 'alert', 'reminder'],
    outline: [
      path(
        M(6.1, 16.6),
        L(6.1, 10.9),
        C(6.1, 7.6, 8.7, 5, 12, 5),
        C(15.3, 5, 17.9, 7.6, 17.9, 10.9),
        L(17.9, 16.6),
        L(19.8, 19),
        L(4.2, 19),
        Z,
      ),
      path(M(9.9, 19), C(9.9, 20.3, 10.8, 21.2, 12, 21.2), C(13.2, 21.2, 14.1, 20.3, 14.1, 19)),
      line(12, 2.9, 12, 5),
    ],
    fillRule: 'nonzero',
    filled: [
      path(
        M(5.8, 16.7),
        L(5.8, 10.9),
        C(5.8, 7.4, 8.6, 4.6, 12, 4.6),
        C(15.4, 4.6, 18.2, 7.4, 18.2, 10.9),
        L(18.2, 16.7),
        L(20.3, 19.3),
        L(3.7, 19.3),
        Z,
      ),
      path(
        M(9.6, 19.6),
        C(9.6, 21, 10.7, 22, 12, 22),
        C(13.3, 22, 14.4, 21, 14.4, 19.6),
        Z,
      ),
      rrect(11, 2, 2, 3.2, 1),
    ],
  },

  message: {
    keywords: ['chat', 'comment', 'bubble'],
    outline: [
      path(
        M(6, 4.6),
        L(18, 4.6),
        C(19.3, 4.6, 20.4, 5.7, 20.4, 7),
        L(20.4, 14.6),
        C(20.4, 15.9, 19.3, 17, 18, 17),
        L(10.6, 17),
        L(6.6, 20.4),
        L(6.6, 17),
        L(6, 17),
        C(4.7, 17, 3.6, 15.9, 3.6, 14.6),
        L(3.6, 7),
        C(3.6, 5.7, 4.7, 4.6, 6, 4.6),
        Z,
      ),
    ],
    filled: [
      path(
        M(6, 4.2),
        L(18, 4.2),
        C(19.5, 4.2, 20.8, 5.5, 20.8, 7),
        L(20.8, 14.6),
        C(20.8, 16.1, 19.5, 17.4, 18, 17.4),
        L(10.8, 17.4),
        L(6.4, 21.2),
        L(6.4, 17.4),
        L(6, 17.4),
        C(4.5, 17.4, 3.2, 16.1, 3.2, 14.6),
        L(3.2, 7),
        C(3.2, 5.5, 4.5, 4.2, 6, 4.2),
        Z,
      ),
    ],
  },

  user: {
    keywords: ['profile', 'account', 'person'],
    outline: [
      circle(12, 8.2, 3.9),
      path(M(4.9, 20.4), C(4.9, 16.5, 8.1, 14, 12, 14), C(15.9, 14, 19.1, 16.5, 19.1, 20.4)),
    ],
    fillRule: 'nonzero',
    filled: [
      circle(12, 8, 4.2),
      path(
        M(4.6, 20.8),
        C(4.6, 16.6, 8, 13.8, 12, 13.8),
        C(16, 13.8, 19.4, 16.6, 19.4, 20.8),
        Z,
      ),
    ],
  },

  leaf: {
    keywords: ['eco', 'fresh', 'impact', 'brand'],
    // Drawn explicitly rather than from leafShape(): a symmetric almond with a
    // centre line collapses into a "Ø" at 16px. The stem running out of the
    // bottom-left is what makes this read as a leaf at every size.
    outline: [
      path(
        M(7, 17),
        C(7, 17, 5.4, 11, 9.5, 6.9),
        C(13.6, 2.8, 19.6, 4.4, 19.6, 4.4),
        C(19.6, 4.4, 21.2, 10.4, 17.1, 14.5),
        C(13, 18.6, 7, 17, 7, 17),
        Z,
      ),
      path(
        M(3.4, 20.6),
        C(5.1, 18.9, 6.2, 17.8, 7, 17),
        C(9.3, 14.7, 11.8, 12.4, 15.2, 10.2),
      ),
    ],
    fillRule: 'nonzero',
    filled: [
      path(
        M(7.1, 17.3),
        C(7.1, 17.3, 5.2, 10.9, 9.4, 6.7),
        C(13.6, 2.5, 20, 4.2, 20, 4.2),
        C(20, 4.2, 21.7, 10.6, 17.5, 14.8),
        C(13.3, 19, 7.1, 17.3, 7.1, 17.3),
        Z,
      ),
      poly([[2.8, 19.9], [6.9, 15.8], [8.2, 17.1], [4.1, 21.2]], true),
    ],
  },

  truck: {
    keywords: ['delivery', 'transport', 'pickup'],
    outline: [
      rrect(2.6, 6.6, 11.4, 9.4, 1.6),
      poly([[14, 9.8], [17.6, 9.8], [20.8, 13], [20.8, 16], [14, 16]], true),
      circle(7.2, 18, 2),
      circle(17, 18, 2),
    ],
    filled: [
      rrect(2.6, 6.6, 11.4, 9.4, 1.6),
      poly([[14, 9.8], [17.6, 9.8], [20.8, 13], [20.8, 16], [14, 16]], true),
      circle(7.2, 18, 2.2),
      circle(7.2, 18, 0.9),
      circle(17, 18, 2.2),
      circle(17, 18, 0.9),
    ],
  },

  package: {
    keywords: ['box', 'parcel', 'portion', 'container'],
    outline: [
      poly([[12, 2.8], [20.8, 7.3], [20.8, 16.7], [12, 21.2], [3.2, 16.7], [3.2, 7.3]], true),
      poly([[3.2, 7.3], [12, 11.8], [20.8, 7.3]]),
      line(12, 11.8, 12, 21.2),
    ],
    filled: [
      poly([[12, 2.6], [21.2, 7.3], [21.2, 16.7], [12, 21.4], [2.8, 16.7], [2.8, 7.3]], true),
    ],
  },

  share: {
    keywords: ['send', 'spread', 'refer'],
    outline: [
      circle(17.8, 5.6, 2.6),
      circle(6.2, 12, 2.6),
      circle(17.8, 18.4, 2.6),
      line(8.5, 10.7, 15.5, 6.9),
      line(8.5, 13.3, 15.5, 17.1),
    ],
    fillRule: 'nonzero',
    filled: [
      circle(17.8, 5.6, 2.8),
      circle(6.2, 12, 2.8),
      circle(17.8, 18.4, 2.8),
      poly([[8.2, 10.2], [15.9, 6], [16.8, 7.6], [9.1, 11.8]], true),
      poly([[9.1, 12.2], [16.8, 16.4], [15.9, 18], [8.2, 13.8]], true),
    ],
  },

  settings: {
    keywords: ['preferences', 'config', 'gear', 'admin'],
    outline: [gear(12, 12, 9.2, 7, 8), circle(12, 12, 3.1)],
    filled: [gear(12, 12, 9.4, 7.1, 8), circle(12, 12, 3.2)],
  },
};

/* ────────────────────────────────────────────────────────────────────────
   Category — §05.5 (outline only, as in the document)
   ──────────────────────────────────────────────────────────────────────── */

const category = {
  food: {
    keywords: ['bowl', 'meal', 'serving'],
    outline: [
      path(arc(12, 11.6, 8, 0, 180), L(4, 11.6), Z),
      line(2.6, 11.6, 21.4, 11.6),
      path(M(9.4, 8.2), C(9.4, 6.6, 11, 6.6, 11, 5)),
      path(M(13, 8.2), C(13, 6.6, 14.6, 6.6, 14.6, 5)),
    ],
  },

  fruitsVeg: {
    keywords: ['produce', 'vegetables', 'fruit', 'fresh'],
    outline: [
      ellipse(11.2, 14.2, 6.4, 6.6),
      leafShape(15.4, 6.9, 5.6, 5.4, 45),
      line(11.2, 7.6, 11.2, 10),
    ],
  },

  bakery: {
    keywords: ['bread', 'loaf', 'baked'],
    outline: [
      rrect(2.8, 8.6, 18.4, 9.4, 4.2),
      line(8.4, 11.4, 6.6, 15.2),
      line(12.4, 11.4, 10.6, 15.2),
      line(16.4, 11.4, 14.6, 15.2),
    ],
  },

  meals: {
    keywords: ['plate', 'cooked', 'dish'],
    outline: [circle(12, 12, 8.6), circle(12, 12, 4.6)],
  },

  beverages: {
    keywords: ['drink', 'juice', 'cup'],
    outline: [
      poly([[6.2, 5.4], [17.8, 5.4], [16.4, 20.6], [7.6, 20.6]], true),
      line(6.6, 10, 17.4, 10),
      line(14.6, 2.6, 13.4, 5.4),
    ],
  },

  dairy: {
    keywords: ['milk', 'curd', 'carton'],
    outline: [
      poly([[7.2, 8.2], [12, 3.4], [16.8, 8.2], [16.8, 20.6], [7.2, 20.6]], true),
      line(7.2, 8.2, 16.8, 8.2),
      line(12, 3.4, 12, 8.2),
    ],
  },

  restaurants: {
    keywords: ['hotel', 'function hall', 'venue', 'donor'],
    outline: [
      poly([[2.8, 9.2], [4.8, 4.4], [19.2, 4.4], [21.2, 9.2]], true),
      poly([[4.4, 9.2], [4.4, 20.6], [19.6, 20.6], [19.6, 9.2]]),
      rrect(9.8, 13.8, 4.4, 6.8, 0.6),
    ],
  },

  cafes: {
    keywords: ['coffee', 'cafe', 'tea'],
    outline: [
      rrect(3.4, 7.2, 12.4, 10.8, 2),
      path(arc(15.8, 11.2, 3.4, -72, 72)),
      line(2.4, 20.8, 19.6, 20.8),
      line(7.4, 2.8, 7.4, 4.8),
      line(11.4, 2.8, 11.4, 4.8),
    ],
  },

  grocery: {
    keywords: ['basket', 'store', 'shop', 'mart'],
    outline: [
      poly([[2.8, 9.4], [21.2, 9.4], [18.8, 19.8], [5.2, 19.8]], true),
      path(arc(12, 9.4, 5, 180, 360)),
      line(9.4, 12.6, 10, 16.8),
      line(14.6, 12.6, 14, 16.8),
    ],
  },

  events: {
    keywords: ['function', 'wedding', 'occasion'],
    outline: [
      rrect(3.4, 5.6, 17.2, 15, 2.4),
      line(3.4, 10.2, 20.6, 10.2),
      line(8, 3.2, 8, 7.2),
      line(16, 3.2, 16, 7.2),
      poly([[12, 12.4], [13.1, 14.7], [15.6, 15], [13.8, 16.8], [14.3, 19.2],
            [12, 18], [9.7, 19.2], [10.2, 16.8], [8.4, 15], [10.9, 14.7]], true),
    ],
  },

  community: {
    keywords: ['people', 'ngo', 'group', 'together'],
    outline: [
      circle(9, 8.4, 3.2),
      path(M(2.8, 19.6), C(2.8, 16.2, 5.6, 13.6, 9, 13.6), C(12.4, 13.6, 15.2, 16.2, 15.2, 19.6)),
      path(M(15.6, 6.2), C(17.6, 6.7, 19, 8.4, 19, 10.4), C(19, 11.5, 18.6, 12.5, 17.9, 13.3)),
      path(M(17.4, 14.6), C(19.6, 15.6, 21.2, 17.4, 21.2, 19.6)),
    ],
  },

  impact: {
    keywords: ['effect', 'change', 'result', 'meals served'],
    outline: [circle(12, 12, 8.8), leafShape(12, 11.9, 8.6, 9.4, 32)],
  },

  wasteReduction: {
    keywords: ['less waste', 'bin', 'rescue'],
    outline: [
      poly([[5.4, 7.6], [6.6, 20.6], [17.4, 20.6], [18.6, 7.6]], true),
      line(3.4, 7.6, 20.6, 7.6),
      poly([[9.4, 7.6], [9.4, 4.6], [14.6, 4.6], [14.6, 7.6]]),
      leafShape(12, 14.6, 6.2, 6.4, 32),
    ],
  },

  recycle: {
    keywords: ['reuse', 'sustainable', 'circular'],
    outline: [
      arc(12, 12, 7.6, 28, 192),
      arrowHead(12, 12, 7.6, 192, 3),
      arc(12, 12, 7.6, 208, 372),
      arrowHead(12, 12, 7.6, 372, 3),
    ],
  },

  verified: {
    keywords: ['approved', 'trusted', 'ngo verified', 'shield'],
    outline: [
      path(
        M(12, 2.8),
        L(20.2, 6.1),
        L(20.2, 11.6),
        C(20.2, 16.6, 16.8, 20.4, 12, 21.4),
        C(7.2, 20.4, 3.8, 16.6, 3.8, 11.6),
        L(3.8, 6.1),
        Z,
      ),
      poly([[8.5, 11.9], [11, 14.4], [15.6, 9.4]]),
    ],
  },

  time: {
    keywords: ['clock', 'window', 'expiry', 'freshness'],
    outline: [circle(12, 12, 8.8), poly([[12, 6.8], [12, 12], [15.8, 14.2]])],
  },

  location: {
    keywords: ['address', 'nearby', 'radius'],
    outline: [
      path(
        M(12, 21.2),
        C(12, 21.2, 18.9, 15.2, 18.9, 10.3),
        C(18.9, 6.5, 15.8, 3.4, 12, 3.4),
        C(8.2, 3.4, 5.1, 6.5, 5.1, 10.3),
        C(5.1, 15.2, 12, 21.2, 12, 21.2),
        Z,
      ),
      circle(12, 10.1, 1.4),
    ],
  },

  help: {
    keywords: ['support', 'question', 'faq'],
    outline: [
      circle(12, 12, 8.8),
      path(
        M(9.3, 9.5),
        C(9.3, 7.9, 10.5, 6.7, 12.1, 6.7),
        C(13.7, 6.7, 14.9, 7.9, 14.9, 9.4),
        C(14.9, 11.5, 12, 11.6, 12, 14),
      ),
      line(12, 16.7, 12, 17.1),
    ],
  },
};


/* ────────────────────────────────────────────────────────────────────────
   UI — the interface furniture §06 and §07 need.
   Not in the PDF's icon pages, which cover brand and category icons only;
   without these the components would have to borrow from another icon
   library and break §05's "don't mix different styles" rule.
   ──────────────────────────────────────────────────────────────────────── */

const ui = {
  check: {
    keywords: ['done', 'confirm', 'success'],
    outline: [poly([[4.8, 12.6], [9.7, 17.5], [19.2, 7.2]])],
  },
  close: {
    keywords: ['dismiss', 'cancel', 'x'],
    outline: [line(6.2, 6.2, 17.8, 17.8), line(17.8, 6.2, 6.2, 17.8)],
  },
  chevronLeft: { keywords: ['back', 'previous'], outline: [poly([[14.6, 5.4], [8, 12], [14.6, 18.6]])] },
  chevronRight: { keywords: ['forward', 'next', 'disclosure'], outline: [poly([[9.4, 5.4], [16, 12], [9.4, 18.6]])] },
  chevronUp: { keywords: ['collapse', 'expand less'], outline: [poly([[5.4, 14.6], [12, 8], [18.6, 14.6]])] },
  chevronDown: { keywords: ['expand', 'dropdown', 'accordion'], outline: [poly([[5.4, 9.4], [12, 16], [18.6, 9.4]])] },
  arrowRight: {
    keywords: ['movement thread', 'onward', 'brand'],
    outline: [line(3.4, 12, 20.6, 12), poly([[14, 5.4], [20.6, 12], [14, 18.6]])],
  },
  arrowLeft: {
    keywords: ['back', 'return'],
    outline: [line(3.4, 12, 20.6, 12), poly([[10, 5.4], [3.4, 12], [10, 18.6]])],
  },
  plus: { keywords: ['add', 'increment'], outline: [line(12, 4.4, 12, 19.6), line(4.4, 12, 19.6, 12)] },
  minus: { keywords: ['remove', 'decrement'], outline: [line(4.4, 12, 19.6, 12)] },
  edit: {
    keywords: ['pencil', 'change', 'draft'],
    outline: [
      poly([[3.6, 20.4], [4.7, 15.5], [16.3, 3.9], [20.1, 7.7], [8.5, 19.3]], true),
      line(13.5, 6.7, 17.3, 10.5),
    ],
  },
  trash: {
    keywords: ['delete', 'remove', 'discard'],
    outline: [
      line(3.6, 6.4, 20.4, 6.4),
      poly([[8.8, 6.4], [8.8, 3.8], [15.2, 3.8], [15.2, 6.4]]),
      poly([[5.9, 6.4], [7, 20.4], [17, 20.4], [18.1, 6.4]]),
      line(10.2, 10, 10.2, 17),
      line(13.8, 10, 13.8, 17),
    ],
  },
  filter: {
    keywords: ['refine', 'facets', 'sort'],
    outline: [poly([[3.4, 5], [20.6, 5], [14, 12.4], [14, 19.2], [10, 21], [10, 12.4]], true)],
  },
  more: {
    keywords: ['overflow', 'actions', 'ellipsis'],
    outline: [circle(5.4, 12, 1.4), circle(12, 12, 1.4), circle(18.6, 12, 1.4)],
  },
  phone: {
    keywords: ['call', 'tap to call', 'contact'],
    outline: [
      path(
        M(8.6, 4.1),
        C(6.1, 4.1, 4.1, 6.1, 4.1, 8.6),
        C(4.1, 15.4, 8.6, 19.9, 15.4, 19.9),
        C(17.9, 19.9, 19.9, 17.9, 19.9, 15.4),
        L(15.5, 14),
        L(13.5, 16),
        C(11.3, 15, 9, 12.7, 8, 10.5),
        L(10, 8.5),
        Z,
      ),
    ],
  },
  star: {
    keywords: ['rating', 'favourite donor', 'review'],
    outline: [
      poly(
        [[12, 3.2], [14.7, 8.9], [21, 9.8], [16.5, 14.2], [17.6, 20.4],
         [12, 17.4], [6.4, 20.4], [7.5, 14.2], [3, 9.8], [9.3, 8.9]],
        true,
      ),
    ],
  },
  upload: {
    keywords: ['proof document', 'photo', 'attach'],
    outline: [
      line(12, 3.6, 12, 15.2),
      poly([[8.2, 7.4], [12, 3.6], [15.8, 7.4]]),
      poly([[4.4, 14.6], [4.4, 19.4], [19.6, 19.4], [19.6, 14.6]]),
    ],
  },
  download: {
    keywords: ['export', 'save'],
    outline: [
      line(12, 3.6, 12, 15.2),
      poly([[8.2, 11.4], [12, 15.2], [15.8, 11.4]]),
      poly([[4.4, 14.6], [4.4, 19.4], [19.6, 19.4], [19.6, 14.6]]),
    ],
  },
  info: {
    keywords: ['about', 'note', 'detail'],
    outline: [circle(12, 12, 8.8), line(12, 11.2, 12, 16.6), line(12, 7.4, 12, 7.8)],
  },
  alert: {
    keywords: ['warning', 'caution', 'problem'],
    outline: [
      poly([[12, 3.6], [21.4, 19.9], [2.6, 19.9]], true),
      line(12, 9.6, 12, 14.2),
      line(12, 16.6, 12, 17),
    ],
  },
  refresh: {
    keywords: ['retry', 'reallocate', 'reload'],
    outline: [arc(12, 12, 7.8, 45, 335), arrowHead(12, 12, 7.8, 335, 3)],
  },
  eye: {
    keywords: ['show', 'visible', 'preview'],
    outline: [
      path(
        M(2.4, 12),
        C(5, 7.4, 8.4, 5.1, 12, 5.1),
        C(15.6, 5.1, 19, 7.4, 21.6, 12),
        C(19, 16.6, 15.6, 18.9, 12, 18.9),
        C(8.4, 18.9, 5, 16.6, 2.4, 12),
        Z,
      ),
      circle(12, 12, 3.2),
    ],
  },
  eyeOff: {
    keywords: ['hide', 'hidden', 'private address'],
    outline: [
      path(
        M(2.4, 12),
        C(5, 7.4, 8.4, 5.1, 12, 5.1),
        C(15.6, 5.1, 19, 7.4, 21.6, 12),
        C(19, 16.6, 15.6, 18.9, 12, 18.9),
        C(8.4, 18.9, 5, 16.6, 2.4, 12),
        Z,
      ),
      circle(12, 12, 3.2),
      line(4.2, 20.4, 19.8, 3.6),
    ],
  },
  menu: {
    keywords: ['hamburger', 'nav'],
    outline: [line(3.6, 6.6, 20.4, 6.6), line(3.6, 12, 20.4, 12), line(3.6, 17.4, 20.4, 17.4)],
  },
  lock: {
    keywords: ['secure', 'private', 'otp'],
    outline: [
      rrect(4.4, 10.2, 15.2, 10.2, 2.2),
      path(M(8, 10.2), L(8, 7.6), C(8, 5.4, 9.8, 3.6, 12, 3.6), C(14.2, 3.6, 16, 5.4, 16, 7.6), L(16, 10.2)),
      line(12, 14, 12, 16.6),
    ],
  },
  logout: {
    keywords: ['sign out', 'exit'],
    outline: [
      path(M(9.6, 20.4), L(5.6, 20.4), C(4.5, 20.4, 3.6, 19.5, 3.6, 18.4), L(3.6, 5.6),
           C(3.6, 4.5, 4.5, 3.6, 5.6, 3.6), L(9.6, 3.6)),
      line(9.4, 12, 20.4, 12),
      poly([[16.4, 8], [20.4, 12], [16.4, 16]]),
    ],
  },
};

/* ──────────────────────────────────────────────────────────────────────── */

export const icons = Object.fromEntries([
  ...Object.entries(core).map(([k, v]) => [k, { ...v, set: 'core' }]),
  ...Object.entries(category).map(([k, v]) => [k, { ...v, set: 'category' }]),
  ...Object.entries(ui).map(([k, v]) => [k, { ...v, set: 'ui' }]),
]);

export const meta = {
  viewBox: 24,
  strokeWidth: 2,
  cap: 'round',
  join: 'round',
};

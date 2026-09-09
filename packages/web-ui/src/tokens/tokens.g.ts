// GENERATED FILE — DO NOT EDIT.
// Source: design/tokens/tokens.json
// Design System v1.0.0
// Regenerate: node design/tools/generate.mjs

export const colors = {
  leafGreen: "#1F6B4A",
  sageGreen: "#4CAF7A",
  harvestOrange: "#E39A1F",
  tomatoRed: "#C2402B",
  sunriseYellow: "#F6C453",
  earthBrown: "#6B4F3B",
  green50: "#F4FAF7",
  green100: "#E6F3EC",
  green300: "#A7D5B9",
  green500: "#4CAF7A",
  green700: "#1F6B4A",
  green900: "#0E3D2C",
  ink: "#15211B",
  inkSoft: "#4A574F",
  surface: "#FAFBF7",
  surfaceAlt: "#F2F4EE",
  border: "#D9E1D6",
  muted: "#A3B1A7",
  white: "#FFFFFF",
  success: "#16A34A",
  onSuccessContainer: "#107D38",
  error: "#DC2626",
  onErrorContainer: "#D32424",
  warning: "#D97706",
  onWarningContainer: "#A95C04",
  info: "#2563EB",
  onInfoContainer: "#2563EB",
  focus: "#7C3AED",
  onFocusContainer: "#7C3AED"
} as const;

export const gradients = {
  nature: "linear-gradient(135deg, #1F6B4A 0%, #4CAF7A 100%)",
  sunrise: "linear-gradient(135deg, #E39A1F 0%, #F6C453 100%)"
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 40,
  huge: 56,
  mega: 72,
  screenPadding: 16,
  cardPadding: 16,
  sectionGap: 24
} as const;

export const radius = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  pill: 999
} as const;

export const shadows = {
  none: "none",
  sm: "0 1px 2px 0px rgba(21, 33, 27, 0.05)",
  md: "0 2px 8px 0px rgba(21, 33, 27, 0.06)",
  lg: "0 6px 20px 0px rgba(21, 33, 27, 0.08)",
  xl: "0 12px 32px 0px rgba(21, 33, 27, 0.1)"
} as const;

export const typography = {
  h1: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 700,
    fontSize: "3.5rem",
    lineHeight: 1.2
  },
  h2: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 600,
    fontSize: "2.5rem",
    lineHeight: 1.2
  },
  h3: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 600,
    fontSize: "2rem",
    lineHeight: 1.2
  },
  h4: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 500,
    fontSize: "1.5rem",
    lineHeight: 1.3
  },
  h5: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 500,
    fontSize: "1.25rem",
    lineHeight: 1.4
  },
  body: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 400,
    fontSize: "1rem",
    lineHeight: 1.6
  },
  small: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 400,
    fontSize: "0.875rem",
    lineHeight: 1.6
  },
  caption: {
    fontFamily: "'Inter', system-ui, sans-serif",
    fontWeight: 400,
    fontSize: "0.75rem",
    lineHeight: 1.6
  },
  display: {
    fontFamily: "'Lora', Georgia, serif",
    fontWeight: 500,
    fontSize: "2.5rem",
    lineHeight: 1.25
  },
  quote: {
    fontFamily: "'Lora', Georgia, serif",
    fontWeight: 400,
    fontSize: "1.25rem",
    lineHeight: 1.5,
    fontStyle: "italic"
  }
} as const;

export const iconSize = {
  xs: 16,
  sm: 20,
  md: 24,
  lg: 32,
  xl: 48
} as const;

export const iconStroke = 2;

export const motion = {
  duration: {
    instant: 100,
    fast: 150,
    normal: 250,
    slow: 400,
    deliberate: 600
  },
  easing: {
    standard: [
      0.2,
      0,
      0,
      1
    ],
    decelerate: [
      0,
      0,
      0.2,
      1
    ],
    accelerate: [
      0.4,
      0,
      1,
      1
    ]
  }
} as const;

export const breakpoints = {
  xs: 0,
  sm: 600,
  md: 905,
  lg: 1240,
  xl: 1440
} as const;

export const a11y = {
  standard: "WCAG 2.2 AA",
  alsoTargets: [
    "ADA",
    "EN 301 549",
    "Section 508"
  ],
  minTapTarget: 44,
  minContrastBodyText: 4.5,
  minContrastLargeText: 3,
  textScaleMax: 2,
  focusRing: {
    width: 2,
    offset: 2,
    color: "#7C3AED"
  },
  $rules: [
    "Logical tab order.",
    "Visible focus indicators.",
    "All interactive elements accessible.",
    "Skip to main content link (web).",
    "Meaningful alt text for images.",
    "Clear and descriptive link and button text.",
    "Meaning is never conveyed by colour alone."
  ]
} as const;

export const status = {
  draft: {
    color: "#A3B1A7",
    text: "#68716A",
    dark: "#A3B1A7",
    surface: "#F2F4EE",
    icon: "edit",
    labelEn: "Draft"
  },
  pendingCheck: {
    color: "#D97706",
    text: "#A95C04",
    dark: "#DC831C",
    surface: "#FDF3E2",
    icon: "time",
    labelEn: "Under review"
  },
  live: {
    color: "#16A34A",
    text: "#107D38",
    dark: "#34AF62",
    surface: "#E6F3EC",
    icon: "check",
    labelEn: "Live"
  },
  allocated: {
    color: "#2563EB",
    text: "#2563EB",
    dark: "#628FF1",
    surface: "#EAF0FE",
    icon: "user",
    labelEn: "Allocated"
  },
  collected: {
    color: "#1F6B4A",
    text: "#1F6B4A",
    dark: "#699C86",
    surface: "#E6F3EC",
    icon: "leaf",
    labelEn: "Collected"
  },
  reallocated: {
    color: "#D97706",
    text: "#A95C04",
    dark: "#DC831C",
    surface: "#FDF3E2",
    icon: "refresh",
    labelEn: "Reallocated"
  },
  unfulfilled: {
    color: "#A3B1A7",
    text: "#68716A",
    dark: "#A3B1A7",
    surface: "#F2F4EE",
    icon: "time",
    labelEn: "Unfulfilled"
  },
  cancelled: {
    color: "#DC2626",
    text: "#D32424",
    dark: "#E66565",
    surface: "#FDECEA",
    icon: "close",
    labelEn: "Cancelled"
  },
  rejected: {
    color: "#DC2626",
    text: "#D32424",
    dark: "#E66565",
    surface: "#FDECEA",
    icon: "alert",
    labelEn: "Rejected"
  },
  urgent: {
    color: "#C2402B",
    text: "#C2402B",
    dark: "#D47768",
    surface: "#FDECEA",
    icon: "alert",
    labelEn: "Urgent"
  }
} as const;

export type ColorToken = keyof typeof colors;
export type SpacingToken = keyof typeof spacing;
export type RadiusToken = keyof typeof radius;
export type StatusToken = keyof typeof status;

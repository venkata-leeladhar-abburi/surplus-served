/**
 * Surplus → Served — MUI theme for the Next.js admin console.
 *
 * Derived entirely from `src/tokens/tokens.g.ts`, which is generated from
 * `design/tokens/tokens.json`. No literal colours, sizes or radii belong in
 * this file — if a value looks wrong, fix the token source and regenerate.
 */

import { createTheme, type Theme, type ThemeOptions } from '@mui/material/styles';

import {
  a11y,
  breakpoints,
  colors,
  gradients,
  motion,
  radius,
  shadows,
  spacing,
  typography as type,
} from '../tokens/tokens.g';

declare module '@mui/material/styles' {
  interface Palette {
    accent: Palette['primary'];
    alert: Palette['primary'];
    brand: { natureGradient: string; sunriseGradient: string };
  }
  interface PaletteOptions {
    accent?: PaletteOptions['primary'];
    alert?: PaletteOptions['primary'];
    brand?: { natureGradient: string; sunriseGradient: string };
  }
  interface TypographyVariants {
    display: React.CSSProperties;
    quote: React.CSSProperties;
  }
  interface TypographyVariantsOptions {
    display?: React.CSSProperties;
    quote?: React.CSSProperties;
  }
}

declare module '@mui/material/Typography' {
  interface TypographyPropsVariantOverrides {
    display: true;
    quote: true;
  }
}

const shared: ThemeOptions = {
  breakpoints: { values: breakpoints },

  shape: { borderRadius: radius.md },

  spacing: (factor: number) => `${factor * 4}px`,

  typography: {
    fontFamily: type.body.fontFamily,
    h1: type.h1,
    h2: type.h2,
    h3: type.h3,
    h4: type.h4,
    h5: type.h5,
    h6: { ...type.body, fontWeight: 600 },
    body1: type.body,
    body2: type.small,
    caption: type.caption,
    display: type.display,
    quote: type.quote,
    button: { ...type.body, fontWeight: 600, textTransform: 'none' },
  },

  components: {
    MuiCssBaseline: {
      styleOverrides: {
        // Respect the reader's motion preference (§10).
        '@media (prefers-reduced-motion: reduce)': {
          '*, *::before, *::after': {
            animationDuration: '0.01ms !important',
            transitionDuration: '0.01ms !important',
          },
        },
        // Visible focus indicator on every interactive element (§10.5).
        ':focus-visible': {
          outline: `${a11y.focusRing.width}px solid ${a11y.focusRing.color}`,
          outlineOffset: `${a11y.focusRing.offset}px`,
        },
      },
    },

    MuiButton: {
      defaultProps: { disableElevation: true },
      styleOverrides: {
        root: {
          borderRadius: radius.md,
          minHeight: a11y.minTapTarget + 4,
          paddingInline: spacing.xl,
          transition: `all ${motion.duration.fast}ms`,
        },
        outlined: { borderWidth: 1.5, '&:hover': { borderWidth: 1.5 } },
      },
    },

    MuiIconButton: {
      styleOverrides: {
        root: { minHeight: a11y.minTapTarget, minWidth: a11y.minTapTarget },
      },
    },

    MuiCard: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          borderRadius: radius.lg,
          border: `1px solid ${colors.border}`,
          backgroundImage: 'none',
        },
      },
    },

    MuiPaper: { styleOverrides: { root: { backgroundImage: 'none' } } },

    MuiChip: {
      styleOverrides: {
        root: { borderRadius: radius.pill, fontWeight: 500 },
      },
    },

    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: radius.md,
          minHeight: a11y.minTapTarget + 4,
          backgroundColor: colors.white,
        },
        notchedOutline: { borderColor: colors.border },
      },
    },

    MuiTableCell: {
      styleOverrides: {
        head: { ...type.small, fontWeight: 600, color: colors.inkSoft },
        root: { borderColor: colors.border },
      },
    },

    MuiTooltip: {
      styleOverrides: {
        tooltip: {
          backgroundColor: colors.white,
          color: colors.ink,
          border: `1px solid ${colors.border}`,
          boxShadow: shadows.md,
          borderRadius: radius.md,
          ...type.small,
        },
      },
    },

    MuiDialog: {
      styleOverrides: { paper: { borderRadius: radius.xl } },
    },
  },
};

export const lightTheme: Theme = createTheme({
  ...shared,
  palette: {
    mode: 'light',
    primary: {
      main: colors.leafGreen,
      light: colors.sageGreen,
      dark: colors.green900,
      contrastText: colors.white,
    },
    secondary: {
      main: colors.sageGreen,
      light: colors.green300,
      dark: colors.leafGreen,
      contrastText: colors.white,
    },
    accent: { main: colors.harvestOrange, contrastText: colors.ink },
    alert: { main: colors.tomatoRed, contrastText: colors.white },
    success: { main: colors.success },
    error: { main: colors.error },
    warning: { main: colors.warning },
    info: { main: colors.info },
    background: { default: colors.surface, paper: colors.white },
    text: {
      primary: colors.ink,
      secondary: colors.inkSoft,
      disabled: colors.muted,
    },
    divider: colors.border,
    brand: {
      natureGradient: gradients.nature,
      sunriseGradient: gradients.sunrise,
    },
  },
});

export const darkTheme: Theme = createTheme({
  ...shared,
  palette: {
    mode: 'dark',
    primary: {
      main: colors.green500,
      light: colors.green300,
      dark: colors.leafGreen,
      contrastText: '#06210F',
    },
    secondary: { main: colors.green300, contrastText: '#06210F' },
    accent: { main: colors.sunriseYellow, contrastText: '#231703' },
    alert: { main: '#E9705A', contrastText: '#2A0B06' },
    success: { main: '#4ADE80' },
    error: { main: '#F87171' },
    warning: { main: '#FBBF24' },
    info: { main: '#60A5FA' },
    background: { default: '#0D1512', paper: '#141F1A' },
    text: {
      primary: '#EAF1EC',
      secondary: '#AFBDB4',
      disabled: '#7C8B82',
    },
    divider: '#2C3A33',
    brand: {
      natureGradient: gradients.nature,
      sunriseGradient: gradients.sunrise,
    },
  },
});

export default lightTheme;

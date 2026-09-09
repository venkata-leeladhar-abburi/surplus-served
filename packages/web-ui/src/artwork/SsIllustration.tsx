import * as React from 'react';
import { useTheme } from '@mui/material/styles';

import { brandArt, illustrations, type BrandArtName, type IllustrationName } from './artwork.g';

export interface SsIllustrationProps
  extends Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt' | 'width' | 'height'> {
  name: IllustrationName;
  width?: number;
  /**
   * Overrides the caption used as alt text. Pass "" to mark the illustration
   * decorative when the heading beside it already says the same thing.
   */
  alt?: string;
}

/**
 * §09 Illustration, cropped from the design document.
 *
 * The assets are raster crops from a flattened PDF, so `nativeWidth` is a real
 * ceiling — asking for much more than that will look soft. In development the
 * component says so rather than letting it slip through review.
 */
export function SsIllustration({ name, width, alt, ...rest }: SsIllustrationProps) {
  const art = illustrations[name];
  const w = width ?? art.nativeWidth;
  const h = Math.round((w / art.nativeWidth) * art.nativeHeight);
  const caption = alt ?? art.caption;

  if (process.env.NODE_ENV !== 'production' && w > art.nativeWidth * 1.75) {
    console.warn(
      `SsIllustration: "${name}" rendered at ${w}px but the asset is only ` +
        `${art.nativeWidth}px wide. It will look soft — use a smaller size, or ` +
        `drop a higher-resolution export over public${art.src}.`,
    );
  }

  return (
    <img
      src={art.src}
      alt={caption}
      width={w}
      height={h}
      loading="lazy"
      decoding="async"
      aria-hidden={caption === '' ? true : undefined}
      {...rest}
    />
  );
}

export type LogoVariant = 'horizontal' | 'stacked' | 'mark';

export interface LogoProps
  extends Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt' | 'width' | 'height'> {
  variant?: LogoVariant;
  /** Height in px. §02.9 sets the digital floor at 24px. */
  height?: number;
  /**
   * Use the reversed lockup (§02.9), for Ink, Leaf Green and photography.
   * Defaults to the theme's mode — the colour wordmark is dark ink and simply
   * disappears on a dark ground.
   */
  reversed?: boolean;
}

const LOGO_ASSET: Record<LogoVariant, BrandArtName> = {
  horizontal: 'logoHorizontal',
  stacked: 'logoStacked',
  mark: 'leafMark',
};

const LOGO_ASSET_REVERSED: Record<LogoVariant, BrandArtName> = {
  horizontal: 'logoHorizontalReversed',
  stacked: 'logoStackedReversed',
  mark: 'leafMarkReversed',
};

/** §02.9 — the rules the mark ships with. */
export const logoRules = {
  minSize: 24,
  clearSpaceRatio: 0.5,
  dont: [
    'Recolour the leaves or the arrow.',
    'Restack or re-space the wordmark.',
    'Crowd the mark inside its clear space.',
    'Substitute the typeface or add effects.',
    'Place the colour mark on a low-contrast photograph.',
  ],
} as const;

/**
 * §02.1 The Surplus → Served logo, straight from the design document.
 *
 * §02.9 forbids recolouring and restacking the mark, so this component takes a
 * size and nothing else — there is deliberately no colour prop.
 */
export function Logo({ variant = 'horizontal', height, reversed, ...rest }: LogoProps) {
  const theme = useTheme();
  const onDark = reversed ?? theme.palette.mode === 'dark';
  const art = brandArt[(onDark ? LOGO_ASSET_REVERSED : LOGO_ASSET)[variant]];
  const h = Math.max(logoRules.minSize, height ?? art.nativeHeight);
  const w = Math.round((h / art.nativeHeight) * art.nativeWidth);

  return (
    <img
      src={art.src}
      alt="Surplus → Served"
      width={w}
      height={h}
      decoding="async"
      {...rest}
    />
  );
}

export { illustrations, brandArt, illustrationNames, brandArtNames, illustrationsBySet } from './artwork.g';
export type { IllustrationName, BrandArtName, Artwork } from './artwork.g';

/**
 * Surplus → Served — web design system.
 *
 * Import from here, never from `tokens/tokens.g.*` or `icons/icons.g.*`
 * directly; those are generated and their shape is an implementation detail.
 */
export * from './tokens/tokens.g';

export { SsIcon } from './icons/SsIcon';
export type { SsIconProps, IconName } from './icons/SsIcon';
export { iconNames, coreIconNames } from './icons/icons.g';

export { SsIllustration, Logo, logoRules } from './artwork/SsIllustration';
export type { SsIllustrationProps, LogoProps, LogoVariant } from './artwork/SsIllustration';
export {
  illustrations,
  brandArt,
  illustrationNames,
  brandArtNames,
  illustrationsBySet,
} from './artwork/artwork.g';
export type { Artwork, IllustrationName, BrandArtName } from './artwork/artwork.g';

export * from './components';

export { lightTheme, darkTheme } from './theme/theme';
export { default as theme } from './theme/theme';

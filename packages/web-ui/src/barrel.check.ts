/**
 * Compile-time guard for the package's public surface.
 *
 * `tsc --noEmit` covers this file, so if a symbol stops being exported from
 * `index.ts` the typecheck fails. Without it a dropped re-export only surfaces
 * when someone tries to import it — which is how `Logo` and `SsIllustration`
 * silently went missing once already.
 *
 * Add an entry here whenever the public API grows.
 */
import type {
  Artwork,
  BrandArtName,
  Column,
  ConfirmDialogProps,
  Crumb,
  EmptyStateProps,
  FilterBarProps,
  FilterOption,
  FreshnessRingProps,
  IconName,
  IllustrationName,
  LogoProps,
  LogoVariant,
  PageHeaderProps,
  SsIconProps,
  SsIllustrationProps,
  StatCardProps,
  StatusChipProps,
  TagProps,
  TagTone,
} from './index';

import {
  ConfirmDialog,
  DataTable,
  EmptyState,
  FilterBar,
  FreshnessRing,
  Logo,
  PageHeader,
  SsIcon,
  SsIllustration,
  StatCard,
  StatusChip,
  Tag,
  brandArt,
  brandArtNames,
  colors,
  coreIconNames,
  darkTheme,
  gradients,
  iconNames,
  iconSize,
  illustrationNames,
  illustrations,
  illustrationsBySet,
  lightTheme,
  logoRules,
  radius,
  shadows,
  spacing,
  status,
  typography,
} from './index';

// Referencing every value keeps the imports from being elided.
export const __publicApi = {
  ConfirmDialog, DataTable, EmptyState, FilterBar, FreshnessRing, Logo,
  PageHeader, SsIcon, SsIllustration, StatCard, StatusChip, Tag,
  brandArt, brandArtNames, colors, coreIconNames, darkTheme, gradients,
  iconNames, iconSize, illustrationNames, illustrations, illustrationsBySet,
  lightTheme, logoRules, radius, shadows, spacing, status, typography,
} as const;

// And every type, so a dropped `export type` fails too.
export type __publicTypes = [
  Artwork, BrandArtName, Column<unknown>, ConfirmDialogProps, Crumb,
  EmptyStateProps, FilterBarProps, FilterOption, FreshnessRingProps, IconName,
  IllustrationName, LogoProps, LogoVariant, PageHeaderProps, SsIconProps,
  SsIllustrationProps, StatCardProps, StatusChipProps, TagProps, TagTone,
];

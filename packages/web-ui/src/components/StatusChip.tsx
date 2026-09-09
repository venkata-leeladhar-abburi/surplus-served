import * as React from 'react';
import Box from '@mui/material/Box';
import { alpha, useTheme } from '@mui/material/styles';

import { SsIcon, type IconName } from '../icons/SsIcon';
import { colors, status as statusTokens, type StatusToken } from '../tokens/tokens.g';

export interface StatusChipProps {
  status: StatusToken;
  /** Localised label. Falls back to the English label carried by the token. */
  label?: string;
  dense?: boolean;
}

/**
 * §06.4 Status badge for the donation lifecycle.
 *
 * Renders the icon and the label alongside the colour — §03 and §10 both
 * forbid conveying meaning by colour alone, which matters most here, where the
 * difference between "Allocated" and "Unfulfilled" decides whether someone
 * drives across the city.
 */
export function StatusChip({ status, label, dense = false }: StatusChipProps) {
  const theme = useTheme();
  const token = statusTokens[status];
  const text = label ?? token.labelEn;

  // The token's `surface` and `text` are the light-theme pair. On dark, tint
  // the paper with the status hue instead — the pale surfaces would otherwise
  // punch bright holes in a dark table.
  const dark = theme.palette.mode === 'dark';
  const bg = dark ? alpha(token.color, 0.18) : token.surface;
  const fg = dark ? token.dark : token.text;

  return (
    <Box
      component="span"
      role="status"
      sx={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: dense ? 0.5 : 0.75,
        px: dense ? 0.75 : 1.25,
        py: dense ? 0.25 : 0.5,
        borderRadius: 999,
        backgroundColor: bg,
        // In light mode `text` is the AA-verified tone against `surface`;
        // `color` is the brand hue and belongs on fills, not on 12px label text.
        color: fg,
        fontSize: dense ? 11 : 13,
        fontWeight: 600,
        lineHeight: 1.4,
        whiteSpace: 'nowrap',
      }}
    >
      <SsIcon name={token.icon as IconName} size={dense ? 'xs' : 'sm'} />
      {text}
    </Box>
  );
}

export type TagTone = 'neutral' | 'positive' | 'warm' | 'info';

export interface TagProps {
  label: string;
  icon?: IconName;
  tone?: TagTone;
}

const TONES: Record<TagTone, { fg: string; bg: string; border?: string }> = {
  neutral: { fg: colors.inkSoft, bg: colors.surfaceAlt, border: colors.border },
  positive: { fg: colors.leafGreen, bg: colors.green100 },
  warm: { fg: colors.onWarningContainer, bg: '#FDF3E2' },
  info: { fg: colors.info, bg: '#EAF0FE' },
};

/** Brand hues to tint with on dark, where the pale surfaces above don't work. */
const DARK_TONES: Record<TagTone, string> = {
  neutral: colors.muted,
  positive: colors.sageGreen,
  warm: colors.harvestOrange,
  info: colors.info,
};

/** §06.4 Content tag — "Vegetarian", "Bulk", "Nearby", "Verified". */
export function Tag({ label, icon, tone = 'neutral' }: TagProps) {
  const theme = useTheme();
  const dark = theme.palette.mode === 'dark';
  const hue = DARK_TONES[tone];
  const t = dark
    ? { fg: hue, bg: alpha(hue, 0.18), border: undefined }
    : TONES[tone];
  return (
    <Box
      component="span"
      sx={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 0.5,
        px: 1.25,
        py: 0.375,
        borderRadius: 999,
        backgroundColor: t.bg,
        color: t.fg,
        border: t.border ? `1px solid ${t.border}` : undefined,
        fontSize: 12,
        fontWeight: 500,
        whiteSpace: 'nowrap',
      }}
    >
      {icon ? <SsIcon name={icon} size="xs" /> : null}
      {label}
    </Box>
  );
}

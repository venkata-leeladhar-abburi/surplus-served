import * as React from 'react';
import Box from '@mui/material/Box';

import { SsIcon, type IconName } from '../icons/SsIcon';
import { status as statusTokens, type StatusToken } from '../tokens/tokens.g';

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
  const token = statusTokens[status];
  const text = label ?? token.labelEn;

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
        backgroundColor: token.surface,
        // `text` is the AA-verified tone against `surface`; `color` is the
        // brand hue and belongs on fills, not on 12px label text.
        color: token.text,
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
  neutral: { fg: '#4A574F', bg: '#F2F4EE', border: '#D9E1D6' },
  positive: { fg: '#1F6B4A', bg: '#E6F3EC' },
  warm: { fg: '#A95C04', bg: '#FDF3E2' },
  info: { fg: '#2563EB', bg: '#EAF0FE' },
};

/** §06.4 Content tag — "Vegetarian", "Bulk", "Nearby", "Verified". */
export function Tag({ label, icon, tone = 'neutral' }: TagProps) {
  const t = TONES[tone];
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

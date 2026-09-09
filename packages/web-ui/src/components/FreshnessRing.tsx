import * as React from 'react';
import Box from '@mui/material/Box';

import { colors } from '../tokens/tokens.g';

export interface FreshnessRingProps {
  /** Minutes left in the pickup window. */
  remainingMinutes: number;
  /** Full length of the window, in minutes. */
  totalMinutes: number;
  size?: number;
}

/**
 * §02.8 "Time & Freshness" — the ring that reminds people to act soon.
 *
 * The colour shifts green → orange → red as the window closes, but the minutes
 * are always spelled out, so the urgency never depends on colour.
 */
export function FreshnessRing({
  remainingMinutes,
  totalMinutes,
  size = 72,
}: FreshnessRingProps) {
  const fraction =
    totalMinutes <= 0 ? 0 : Math.min(1, Math.max(0, remainingMinutes / totalMinutes));

  const color =
    fraction >= 0.5 ? colors.leafGreen : fraction >= 0.2 ? colors.warning : colors.tomatoRed;

  const label =
    remainingMinutes >= 60
      ? `${Math.floor(remainingMinutes / 60)} hr left`
      : remainingMinutes > 0
        ? `${remainingMinutes} min left`
        : 'Window closed';

  const stroke = 4;
  const r = (size - stroke) / 2;
  const circumference = 2 * Math.PI * r;

  return (
    <Box
      role="img"
      aria-label={`Pickup window: ${label}`}
      sx={{ position: 'relative', width: size, height: size, display: 'inline-block' }}
    >
      <svg width={size} height={size} aria-hidden focusable="false">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={colors.surfaceAlt}
          strokeWidth={stroke}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={color}
          strokeWidth={stroke}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - fraction)}
          transform={`rotate(-90 ${size / 2} ${size / 2})`}
        />
      </svg>
      <Box
        aria-hidden
        sx={{
          position: 'absolute',
          inset: 0,
          display: 'grid',
          placeItems: 'center',
          textAlign: 'center',
          fontSize: size * 0.16,
          fontWeight: 600,
          lineHeight: 1.2,
          color,
          px: 1,
        }}
      >
        {label}
      </Box>
    </Box>
  );
}

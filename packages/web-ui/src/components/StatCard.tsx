import * as React from 'react';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

import { SsIcon, type IconName } from '../icons/SsIcon';

export interface StatCardProps {
  label: string;
  value: string;
  icon?: IconName;
  /** e.g. "+18% from last month". Sign drives the colour and the arrow. */
  delta?: string;
  deltaDirection?: 'up' | 'down' | 'flat';
  sparkline?: number[];
}

/**
 * §06.3 Stat tile — "1,240 kg Food Saved This Month".
 *
 * The delta carries an arrow icon as well as a colour, so the direction
 * survives a greyscale print and a colour-blind reader (§03.10).
 */
export function StatCard({
  label,
  value,
  icon = 'leaf',
  delta,
  deltaDirection = 'flat',
  sparkline,
}: StatCardProps) {
  const deltaColor =
    deltaDirection === 'up'
      ? 'success.main'
      : deltaDirection === 'down'
        ? 'error.main'
        : 'text.secondary';

  const max = sparkline && sparkline.length ? Math.max(...sparkline) : 0;

  return (
    <Card>
      <CardContent>
        <Stack spacing={1.5}>
          <Box sx={{ color: 'primary.main', display: 'flex' }}>
            <SsIcon name={icon} size="lg" />
          </Box>

          <Box>
            <Typography variant="h3" component="p" sx={{ lineHeight: 1.1 }}>
              {value}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {label}
            </Typography>
          </Box>

          {sparkline && sparkline.length > 0 && (
            <Stack direction="row" alignItems="flex-end" spacing={0.5} sx={{ height: 48 }}>
              {sparkline.map((v, i) => (
                <Box
                  key={i}
                  aria-hidden
                  sx={{
                    flex: 1,
                    height: max === 0 ? 2 : `${Math.max(6, (v / max) * 100)}%`,
                    borderRadius: 1,
                    backgroundColor: 'primary.main',
                    opacity: 0.25 + (0.75 * (i + 1)) / sparkline.length,
                  }}
                />
              ))}
            </Stack>
          )}

          {delta && (
            <Stack direction="row" spacing={0.5} alignItems="center" sx={{ color: deltaColor }}>
              <SsIcon name={deltaDirection === 'down' ? 'chevronDown' : 'chevronUp'} size="xs" />
              <Typography variant="body2" sx={{ color: 'inherit', fontWeight: 600 }}>
                {delta}
              </Typography>
            </Stack>
          )}
        </Stack>
      </CardContent>
    </Card>
  );
}

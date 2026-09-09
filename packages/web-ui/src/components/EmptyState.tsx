import * as React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';

import { SsIcon, type IconName } from '../icons/SsIcon';

export interface EmptyStateProps {
  title: string;
  message: string;
  icon?: IconName;
  primaryActionLabel?: string;
  onPrimaryAction?: () => void;
  secondaryActionLabel?: string;
  onSecondaryAction?: () => void;
  /** "Try this next" hints — §07.5 shows three by default. */
  suggestions?: string[];
}

/**
 * §07.12 Empty state.
 *
 * "Turn empty moments into helpful guidance" — every empty state names what is
 * missing and offers the next best action, rather than leaving a blank panel.
 */
export function EmptyState({
  title,
  message,
  icon = 'receive',
  primaryActionLabel,
  onPrimaryAction,
  secondaryActionLabel,
  onSecondaryAction,
  suggestions = [],
}: EmptyStateProps) {
  return (
    <Stack alignItems="center" spacing={2} sx={{ py: 8, px: 3, textAlign: 'center' }}>
      <Box
        sx={{
          width: 96,
          height: 96,
          borderRadius: '50%',
          display: 'grid',
          placeItems: 'center',
          backgroundColor: 'primary.main',
          opacity: 0.12,
          position: 'relative',
        }}
      />
      <Box sx={{ mt: -9, color: 'primary.main' }}>
        <SsIcon name={icon} size="xl" />
      </Box>

      <Typography variant="h4" sx={{ mt: 2 }}>
        {title}
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ maxWidth: 420 }}>
        {message}
      </Typography>

      {(primaryActionLabel || secondaryActionLabel) && (
        <Stack direction="row" spacing={1.5} sx={{ pt: 1 }}>
          {primaryActionLabel && (
            <Button variant="contained" onClick={onPrimaryAction}>
              {primaryActionLabel}
            </Button>
          )}
          {secondaryActionLabel && (
            <Button variant="outlined" onClick={onSecondaryAction}>
              {secondaryActionLabel}
            </Button>
          )}
        </Stack>
      )}

      {suggestions.length > 0 && (
        <Stack spacing={1} sx={{ pt: 2, textAlign: 'left' }}>
          <Typography variant="body2" fontWeight={600} color="text.secondary">
            Suggestions
          </Typography>
          {suggestions.map((s) => (
            <Stack key={s} direction="row" spacing={1} alignItems="center">
              <Box sx={{ color: 'accent.main', display: 'flex' }}>
                <SsIcon name="info" size="sm" />
              </Box>
              <Typography variant="body2" color="text.secondary">
                {s}
              </Typography>
            </Stack>
          ))}
        </Stack>
      )}
    </Stack>
  );
}

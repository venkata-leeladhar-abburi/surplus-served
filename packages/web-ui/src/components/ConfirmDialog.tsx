import * as React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';

import { SsIcon, type IconName } from '../icons/SsIcon';

export interface ConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  icon?: IconName;
  /** Renders the confirm button in the alert colour and swaps the icon. */
  destructive?: boolean;
  busy?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

/**
 * §06.7 Modal confirmation.
 *
 * Admin overrides (force-allocate, revoke, suspend) are consequential and hard
 * to undo, so they route through here rather than firing on a single click.
 */
export function ConfirmDialog({
  open,
  title,
  message,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  icon = 'leaf',
  destructive = false,
  busy = false,
  onConfirm,
  onCancel,
}: ConfirmDialogProps) {
  return (
    <Dialog
      open={open}
      onClose={busy ? undefined : onCancel}
      maxWidth="xs"
      fullWidth
      aria-labelledby="ss-confirm-title"
      aria-describedby="ss-confirm-message"
    >
      <DialogContent>
        <Stack alignItems="center" spacing={2} sx={{ textAlign: 'center', pt: 2 }}>
          <Box
            sx={{
              width: 64,
              height: 64,
              borderRadius: '50%',
              display: 'grid',
              placeItems: 'center',
              backgroundColor: destructive ? 'error.main' : 'primary.main',
              color: 'common.white',
            }}
          >
            <SsIcon name={destructive ? 'alert' : icon} size="lg" />
          </Box>
          <Typography id="ss-confirm-title" variant="h4">
            {title}
          </Typography>
          <Typography id="ss-confirm-message" variant="body1" color="text.secondary">
            {message}
          </Typography>
        </Stack>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 3, gap: 1.5 }}>
        <Button fullWidth variant="outlined" onClick={onCancel} disabled={busy}>
          {cancelLabel}
        </Button>
        <Button
          fullWidth
          variant="contained"
          color={destructive ? 'error' : 'primary'}
          onClick={onConfirm}
          disabled={busy}
        >
          {confirmLabel}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

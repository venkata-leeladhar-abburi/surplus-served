import * as React from 'react';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import InputAdornment from '@mui/material/InputAdornment';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';

import { SsIcon } from '../icons/SsIcon';

export interface FilterOption {
  id: string;
  label: string;
}

export interface FilterBarProps {
  searchValue: string;
  onSearchChange: (value: string) => void;
  searchPlaceholder?: string;
  options?: FilterOption[];
  selected?: string[];
  onToggle?: (id: string) => void;
  onClearAll?: () => void;
}

/**
 * §07.3 Search and filter row.
 *
 * Active filters stay visible as chips rather than hiding behind a button —
 * an admin scanning a live-ops feed has to be able to see, at a glance, why a
 * donation they expected is not in the list.
 */
export function FilterBar({
  searchValue,
  onSearchChange,
  searchPlaceholder = 'Search food, locations, or organizations…',
  options = [],
  selected = [],
  onToggle,
  onClearAll,
}: FilterBarProps) {
  return (
    <Stack spacing={1.5} sx={{ mb: 3 }}>
      <TextField
        value={searchValue}
        onChange={(e) => onSearchChange(e.target.value)}
        placeholder={searchPlaceholder}
        fullWidth
        inputProps={{ 'aria-label': 'Search' }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <SsIcon name="search" size="sm" />
            </InputAdornment>
          ),
        }}
      />

      {options.length > 0 && (
        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap alignItems="center">
          {options.map((opt) => {
            const on = selected.includes(opt.id);
            return (
              <Chip
                key={opt.id}
                label={opt.label}
                onClick={() => onToggle?.(opt.id)}
                color={on ? 'primary' : 'default'}
                variant={on ? 'filled' : 'outlined'}
                aria-pressed={on}
              />
            );
          })}
          {selected.length > 0 && onClearAll && (
            <Button size="small" onClick={onClearAll}>
              Clear all
            </Button>
          )}
        </Stack>
      )}
    </Stack>
  );
}

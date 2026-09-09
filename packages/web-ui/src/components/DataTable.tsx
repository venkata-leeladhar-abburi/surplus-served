import * as React from 'react';
import Box from '@mui/material/Box';
import Checkbox from '@mui/material/Checkbox';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import TableSortLabel from '@mui/material/TableSortLabel';
import Typography from '@mui/material/Typography';

import { EmptyState } from './EmptyState';

export interface Column<Row> {
  id: string;
  header: string;
  /** Cell renderer. Return a string for plain text. */
  render: (row: Row) => React.ReactNode;
  sortable?: boolean;
  align?: 'left' | 'right' | 'center';
  width?: number | string;
}

export interface DataTableProps<Row> {
  columns: Column<Row>[];
  rows: Row[];
  getRowId: (row: Row) => string;
  caption: string;
  selectable?: boolean;
  selected?: string[];
  onSelectionChange?: (ids: string[]) => void;
  sortBy?: string;
  sortDirection?: 'asc' | 'desc';
  onSort?: (columnId: string, direction: 'asc' | 'desc') => void;
  onRowClick?: (row: Row) => void;
  emptyTitle?: string;
  emptyMessage?: string;
}

/**
 * §07.1 Data table for the admin console.
 *
 * `caption` is required and rendered as a visually-hidden <caption>: a table
 * with no accessible name is one of the most common screen-reader failures,
 * and §10 commits the product to AA.
 *
 * The container scrolls horizontally on its own so the page body never does.
 */
export function DataTable<Row>({
  columns,
  rows,
  getRowId,
  caption,
  selectable = false,
  selected = [],
  onSelectionChange,
  sortBy,
  sortDirection = 'asc',
  onSort,
  onRowClick,
  emptyTitle = 'Nothing here yet',
  emptyMessage = 'Rows will appear as soon as there is activity.',
}: DataTableProps<Row>) {
  const allIds = rows.map(getRowId);
  const allSelected = rows.length > 0 && selected.length === rows.length;
  const someSelected = selected.length > 0 && !allSelected;

  if (rows.length === 0) {
    return (
      <Paper variant="outlined">
        <EmptyState title={emptyTitle} message={emptyMessage} icon="search" />
      </Paper>
    );
  }

  return (
    <TableContainer component={Paper} variant="outlined" sx={{ overflowX: 'auto' }}>
      <Table size="small">
        <caption
          style={{
            position: 'absolute',
            width: 1,
            height: 1,
            overflow: 'hidden',
            clip: 'rect(0 0 0 0)',
            whiteSpace: 'nowrap',
          }}
        >
          {caption}
        </caption>

        <TableHead>
          <TableRow>
            {selectable && (
              <TableCell padding="checkbox">
                <Checkbox
                  checked={allSelected}
                  indeterminate={someSelected}
                  onChange={(e) => onSelectionChange?.(e.target.checked ? allIds : [])}
                  inputProps={{ 'aria-label': 'Select all rows' }}
                />
              </TableCell>
            )}
            {columns.map((col) => (
              <TableCell key={col.id} align={col.align} style={{ width: col.width }}>
                {col.sortable && onSort ? (
                  <TableSortLabel
                    active={sortBy === col.id}
                    direction={sortBy === col.id ? sortDirection : 'asc'}
                    onClick={() =>
                      onSort(col.id, sortBy === col.id && sortDirection === 'asc' ? 'desc' : 'asc')
                    }
                  >
                    {col.header}
                  </TableSortLabel>
                ) : (
                  col.header
                )}
              </TableCell>
            ))}
          </TableRow>
        </TableHead>

        <TableBody>
          {rows.map((row) => {
            const id = getRowId(row);
            const isSelected = selected.includes(id);
            return (
              <TableRow
                key={id}
                hover
                selected={isSelected}
                onClick={onRowClick ? () => onRowClick(row) : undefined}
                sx={onRowClick ? { cursor: 'pointer' } : undefined}
              >
                {selectable && (
                  <TableCell padding="checkbox">
                    <Checkbox
                      checked={isSelected}
                      onClick={(e) => e.stopPropagation()}
                      onChange={(e) =>
                        onSelectionChange?.(
                          e.target.checked
                            ? [...selected, id]
                            : selected.filter((s) => s !== id),
                        )
                      }
                      inputProps={{ 'aria-label': `Select row ${id}` }}
                    />
                  </TableCell>
                )}
                {columns.map((col) => (
                  <TableCell key={col.id} align={col.align}>
                    {col.render(row)}
                  </TableCell>
                ))}
              </TableRow>
            );
          })}
        </TableBody>
      </Table>

      {selectable && selected.length > 0 && (
        <Box sx={{ px: 2, py: 1.5, borderTop: 1, borderColor: 'divider' }}>
          <Stack direction="row" alignItems="center" spacing={1}>
            <Typography variant="body2" aria-live="polite">
              {selected.length} selected
            </Typography>
          </Stack>
        </Box>
      )}
    </TableContainer>
  );
}

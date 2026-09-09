import * as React from 'react';
import Box from '@mui/material/Box';
import Breadcrumbs from '@mui/material/Breadcrumbs';
import Link from '@mui/material/Link';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';

export interface Crumb {
  label: string;
  href?: string;
}

export interface PageHeaderProps {
  title: string;
  description?: string;
  crumbs?: Crumb[];
  actions?: React.ReactNode;
}

/** Standard page masthead for the admin console. */
export function PageHeader({ title, description, crumbs, actions }: PageHeaderProps) {
  return (
    <Box component="header" sx={{ mb: 4 }}>
      {crumbs && crumbs.length > 0 && (
        <Breadcrumbs sx={{ mb: 1 }} aria-label="Breadcrumb">
          {crumbs.map((c) =>
            c.href ? (
              <Link key={c.label} href={c.href} underline="hover" color="text.secondary">
                {c.label}
              </Link>
            ) : (
              <Typography key={c.label} color="text.primary">
                {c.label}
              </Typography>
            ),
          )}
        </Breadcrumbs>
      )}

      <Stack
        direction={{ xs: 'column', sm: 'row' }}
        justifyContent="space-between"
        alignItems={{ xs: 'flex-start', sm: 'center' }}
        spacing={2}
      >
        <Box>
          <Typography variant="h3" component="h1">
            {title}
          </Typography>
          {description && (
            <Typography variant="body1" color="text.secondary" sx={{ mt: 0.5, maxWidth: 640 }}>
              {description}
            </Typography>
          )}
        </Box>
        {actions && <Stack direction="row" spacing={1.5}>{actions}</Stack>}
      </Stack>
    </Box>
  );
}

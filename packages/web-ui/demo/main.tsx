/**
 * Web design system gallery.
 *
 *   npm --workspace @surplus-served/web-ui run demo
 *
 * Renders every React component so the admin console's building blocks can be
 * reviewed the same way the Flutter goldens are — by looking at them.
 */
import * as React from 'react';
import { createRoot } from 'react-dom/client';

import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Checkbox from '@mui/material/Checkbox';
import CssBaseline from '@mui/material/CssBaseline';
import Divider from '@mui/material/Divider';
import FormControlLabel from '@mui/material/FormControlLabel';
import MenuItem from '@mui/material/MenuItem';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import Slider from '@mui/material/Slider';
import Stack from '@mui/material/Stack';
import Switch from '@mui/material/Switch';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { ThemeProvider } from '@mui/material/styles';

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
  coreIconNames,
  lightTheme,
  darkTheme,
  type Column,
} from '../src';

interface Donation {
  id: string;
  food: string;
  donor: string;
  qty: string;
  status: 'live' | 'allocated' | 'collected' | 'pendingCheck';
  date: string;
}

const ROWS: Donation[] = [
  { id: '1', food: 'Veg Pulao', donor: 'Green Bites Café', qty: '12 kg', status: 'live', date: 'Aug 12, 2024' },
  { id: '2', food: 'Samosas', donor: 'Hotel Sunrise', qty: '50 pcs', status: 'allocated', date: 'Aug 12, 2024' },
  { id: '3', food: 'Fresh Fruits', donor: 'FreshMart', qty: '20 kg', status: 'collected', date: 'Aug 11, 2024' },
  { id: '4', food: 'Bread Loaves', donor: 'Daily Bakery', qty: '30 pcs', status: 'pendingCheck', date: 'Aug 11, 2024' },
];

const COLUMNS: Column<Donation>[] = [
  { id: 'food', header: 'Food Item', render: (r) => <strong>{r.food}</strong> },
  { id: 'donor', header: 'Donor', render: (r) => r.donor },
  { id: 'qty', header: 'Quantity', render: (r) => r.qty },
  { id: 'status', header: 'Status', render: (r) => <StatusChip status={r.status} dense /> },
  { id: 'date', header: 'Date', render: (r) => r.date },
];

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Box sx={{ mb: 5 }}>
      <Typography
        variant="body2"
        sx={{ color: 'primary.main', fontWeight: 600, letterSpacing: 1.2, mb: 1.5 }}
      >
        {title.toUpperCase()}
      </Typography>
      {children}
    </Box>
  );
}

function Gallery() {
  const [selected, setSelected] = React.useState<string[]>(['2']);
  const [filters, setFilters] = React.useState<string[]>(['meals']);
  const [search, setSearch] = React.useState('');
  const [tab, setTab] = React.useState(0);
  const [confirmOpen, setConfirmOpen] = React.useState(false);

  return (
    <Box sx={{ p: 5, maxWidth: 1180, mx: 'auto' }}>
      <PageHeader
        title="Web design system"
        description="Every React component in @surplus-served/web-ui, rendered."
        crumbs={[{ label: 'Admin', href: '#' }, { label: 'Design system' }]}
        actions={<Button variant="contained">Create Listing</Button>}
      />

      <Section title="Logo (§02.1)">
        <Stack direction="row" spacing={5} alignItems="center">
          <Logo variant="horizontal" height={40} />
          <Logo variant="stacked" height={70} />
          <Logo variant="mark" height={40} />
        </Stack>
      </Section>

      <Section title="Buttons and form primitives — MUI, styled by the theme">
        <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap sx={{ mb: 2 }}>
          <Button variant="contained">Donate Food</Button>
          <Button variant="outlined">Find Nearby</Button>
          <Button variant="text">Learn More</Button>
          <Button variant="contained" color="error">Cancel Listing</Button>
          <Button variant="contained" disabled>Disabled</Button>
        </Stack>
        <Stack direction="row" spacing={3} alignItems="center" flexWrap="wrap" useFlexGap>
          <TextField label="Food name" placeholder="Veg Biryani" size="small" sx={{ minWidth: 220 }} />
          <TextField label="Food type" select defaultValue="meals" size="small" sx={{ minWidth: 180 }}>
            <MenuItem value="meals">Cooked Meals</MenuItem>
            <MenuItem value="bakery">Bakery</MenuItem>
          </TextField>
          <FormControlLabel control={<Checkbox defaultChecked />} label="Splittable" />
          <RadioGroup row defaultValue="individual">
            <FormControlLabel value="individual" control={<Radio />} label="Individual" />
            <FormControlLabel value="org" control={<Radio />} label="Organization" />
          </RadioGroup>
          <FormControlLabel control={<Switch defaultChecked />} label="Notifications" />
        </Stack>
        <Box sx={{ maxWidth: 320, mt: 2 }}>
          <Typography variant="body2" color="text.secondary">Distance</Typography>
          <Slider defaultValue={25} min={0} max={50} valueLabelDisplay="auto" />
        </Box>
      </Section>

      <Section title="Status chips and tags (§06.4)">
        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap sx={{ mb: 2 }}>
          {(['draft', 'pendingCheck', 'live', 'allocated', 'collected', 'reallocated',
             'unfulfilled', 'cancelled', 'rejected', 'urgent'] as const).map((s) => (
            <StatusChip key={s} status={s} />
          ))}
        </Stack>
        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
          <Tag label="Vegetarian" icon="leaf" tone="positive" />
          <Tag label="High Demand" icon="alert" tone="warm" />
          <Tag label="Verified" icon="verified" tone="info" />
          <Tag label="Bulk" />
          <Tag label="Nearby" icon="location" />
        </Stack>
      </Section>

      <Section title="Stat cards (§06.3) and freshness ring (§02.8)">
        <Stack direction="row" spacing={3} alignItems="flex-start" flexWrap="wrap" useFlexGap>
          <Box sx={{ flex: '1 1 240px', minWidth: 240 }}>
            <StatCard
              label="Food Saved This Month" value="1,240 kg" icon="leaf"
              delta="+18% from last month" deltaDirection="up"
              sparkline={[3, 4, 3.5, 5, 4.5, 6, 5.5, 7, 8]}
            />
          </Box>
          <Box sx={{ flex: '1 1 240px', minWidth: 240 }}>
            <StatCard label="People Served" value="320" icon="community" delta="+12%" deltaDirection="up" />
          </Box>
          <Box sx={{ flex: '1 1 240px', minWidth: 240 }}>
            <StatCard label="Unfulfilled" value="4" icon="time" delta="-2 from last week" deltaDirection="down" />
          </Box>
          <Stack direction="row" spacing={2} alignItems="center" sx={{ flex: '0 0 auto' }}>
            <FreshnessRing remainingMinutes={42} totalMinutes={60} />
            <FreshnessRing remainingMinutes={8} totalMinutes={60} />
          </Stack>
        </Stack>
      </Section>

      <Section title="Search, filters and tabs (§07.3, §07.4)">
        <FilterBar
          searchValue={search}
          onSearchChange={setSearch}
          options={[
            { id: 'meals', label: 'Cooked Meals' },
            { id: 'bakery', label: 'Bakery' },
            { id: 'produce', label: 'Fruits & Veg' },
            { id: 'dairy', label: 'Dairy' },
          ]}
          selected={filters}
          onToggle={(id) =>
            setFilters((f) => (f.includes(id) ? f.filter((x) => x !== id) : [...f, id]))
          }
          onClearAll={() => setFilters([])}
        />
        <Tabs value={tab} onChange={(_, v) => setTab(v)}>
          <Tab label="Available" /><Tab label="Requested" />
          <Tab label="Completed" /><Tab label="Cancelled" />
        </Tabs>
      </Section>

      <Section title="Data table (§07.1)">
        <DataTable<Donation>
          caption="Donations, with status and donor"
          columns={COLUMNS}
          rows={ROWS}
          getRowId={(r) => r.id}
          selectable
          selected={selected}
          onSelectionChange={setSelected}
          sortBy="date"
          sortDirection="desc"
          onSort={() => {}}
        />
      </Section>

      <Section title="Icons (§05) — core set, outline and filled">
        <Stack direction="row" spacing={2.5} flexWrap="wrap" useFlexGap sx={{ color: 'text.primary', mb: 2 }}>
          {coreIconNames.map((n) => <SsIcon key={n} name={n} size="lg" />)}
        </Stack>
        <Stack direction="row" spacing={2.5} flexWrap="wrap" useFlexGap sx={{ color: 'primary.main' }}>
          {coreIconNames.map((n) => <SsIcon key={n} name={n} size="lg" filled />)}
        </Stack>
      </Section>

      <Section title="Illustrations (§09)">
        <Stack direction="row" spacing={3} flexWrap="wrap" useFlexGap alignItems="flex-end">
          {(['noFoodAvailable', 'nothingHereYet', 'requestSubmitted', 'foodReceived',
             'safeFood', 'verifiedDonor', 'somethingWentWrong', 'offline'] as const).map((n) => (
            <SsIllustration key={n} name={n} width={104} />
          ))}
        </Stack>
      </Section>

      <Section title="Empty state (§07.12)">
        <EmptyState
          illustration="noResultsFound"
          title="No results found"
          message="We couldn't find any food matching your search. Try different keywords or adjust your filters."
          primaryActionLabel="Clear Filters"
          secondaryActionLabel="Expand Search Area"
          suggestions={['Expand your search area', 'Enable notifications', 'Check again later']}
        />
      </Section>

      <Section title="Confirm dialog (§06.7)">
        <Button variant="outlined" color="error" onClick={() => setConfirmOpen(true)}>
          Revoke NGO…
        </Button>
        <ConfirmDialog
          open={confirmOpen}
          title="Revoke this NGO?"
          message="Helping Hands NGO will lose access immediately and cannot receive new allocations."
          confirmLabel="Revoke"
          destructive
          onConfirm={() => setConfirmOpen(false)}
          onCancel={() => setConfirmOpen(false)}
        />
      </Section>
    </Box>
  );
}

function App() {
  const [dark, setDark] = React.useState(false);
  return (
    <ThemeProvider theme={dark ? darkTheme : lightTheme}>
      <CssBaseline />
      <Box sx={{ minHeight: '100vh', bgcolor: 'background.default' }}>
        <Box sx={{ p: 2, textAlign: 'right' }}>
          <FormControlLabel
            control={<Switch checked={dark} onChange={(e) => setDark(e.target.checked)} />}
            label="Dark theme"
          />
        </Box>
        <Divider />
        <Gallery />
      </Box>
    </ThemeProvider>
  );
}

createRoot(document.getElementById('root')!).render(<App />);

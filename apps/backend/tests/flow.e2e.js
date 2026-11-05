const { call, step, assert, pngBlob } = require('./run-e2e.js');

const ctx = {};

function ngoForm(email, org) {
  const f = new FormData();
  f.append('name', 'NGO Contact');
  f.append('email', email);
  f.append('password', 'password123');
  f.append('role', 'ngo');
  f.append('organizationName', org);
  f.append('registrationNumber', 'REG-' + org);
  f.append('certificate', pngBlob(), 'cert.png');
  return f;
}

// ---------------- Admin bootstrap ----------------
step('setup-admin rejects wrong secret', async () => {
  const r = await call('POST', '/auth/setup-admin', {
    body: { name: 'Admin', email: 'admin@test.io', password: 'adminpassword1', setupSecret: 'nope' },
  });
  assert.strictEqual(r.status, 403);
});

step('setup-admin creates the first admin', async () => {
  const r = await call('POST', '/auth/setup-admin', {
    body: { name: 'Admin', email: 'admin@test.io', password: 'adminpassword1', setupSecret: 'test-setup-secret' },
  });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  assert.strictEqual(r.json.admin.role, 'admin');
  assert.strictEqual(r.json.admin.password, undefined);
});

step('setup-admin refuses a second admin', async () => {
  const r = await call('POST', '/auth/setup-admin', {
    body: { name: 'A2', email: 'admin2@test.io', password: 'adminpassword1', setupSecret: 'test-setup-secret' },
  });
  assert.strictEqual(r.status, 409);
});

step('register cannot create an admin', async () => {
  const r = await call('POST', '/auth/register', {
    body: { name: 'X', email: 'x@test.io', password: 'password123', role: 'admin' },
  });
  assert.strictEqual(r.status, 400);
});

step('admin logs in', async () => {
  const r = await call('POST', '/auth/login', { body: { email: 'admin@test.io', password: 'adminpassword1' } });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.role, 'admin');
  ctx.admin = r.json.token;
});

// ---------------- Registration ----------------
step('donor registers', async () => {
  const r = await call('POST', '/auth/register', {
    body: { name: 'Donor One', email: 'donor@test.io', password: 'password123', role: 'donor' },
  });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  ctx.donor = r.json.token;
});

step('two NGOs register with certificates', async () => {
  for (const [email, org] of [['ngo1@test.io', 'Helping Hands'], ['ngo2@test.io', 'Food Bank']]) {
    const r = await call('POST', '/auth/register', { form: ngoForm(email, org) });
    assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  }
  const bad = await call('POST', '/auth/register', { form: ngoForm('ngo3@test.io', 'Rejected Org') });
  assert.strictEqual(bad.status, 201);
});

step('pending NGO cannot log in', async () => {
  const r = await call('POST', '/auth/login', { body: { email: 'ngo1@test.io', password: 'password123' } });
  assert.strictEqual(r.status, 403);
  assert.strictEqual(r.json.verificationStatus, 'pending');
});

// ---------------- Admin verification ----------------
step('non-admin cannot use admin API', async () => {
  const r = await call('GET', '/admin/ngos/pending', { token: ctx.donor });
  assert.strictEqual(r.status, 403);
});

step('admin sees pending NGOs with certificate URL', async () => {
  const r = await call('GET', '/admin/ngos?status=pending', { token: ctx.admin });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.count, 3);
  for (const n of r.json.ngos) {
    assert.ok(n.ngoDetails.documentUrl, 'documentUrl present');
    assert.strictEqual(n.password, undefined);
    ctx[n.email] = n._id;
  }
  const legacy = await call('GET', '/admin/ngos/pending', { token: ctx.admin });
  assert.strictEqual(legacy.json.count, 3);
});

step('admin approves two NGOs and rejects one with a reason', async () => {
  for (const e of ['ngo1@test.io', 'ngo2@test.io']) {
    const r = await call('PATCH', `/admin/ngos/${ctx[e]}/approve`, { token: ctx.admin });
    assert.strictEqual(r.status, 200);
    assert.strictEqual(r.json.ngo.ngoDetails.verificationStatus, 'verified');
  }
  const noReason = await call('PATCH', `/admin/ngos/${ctx['ngo3@test.io']}/reject`, { token: ctx.admin, body: {} });
  assert.strictEqual(noReason.status, 400);
  const r = await call('PATCH', `/admin/ngos/${ctx['ngo3@test.io']}/reject`, {
    token: ctx.admin, body: { reason: 'Certificate unreadable' },
  });
  assert.strictEqual(r.status, 200);
});

step('rejected NGO login returns reason; verified NGOs log in', async () => {
  const rej = await call('POST', '/auth/login', { body: { email: 'ngo3@test.io', password: 'password123' } });
  assert.strictEqual(rej.status, 403);
  assert.strictEqual(rej.json.rejectionReason, 'Certificate unreadable');
  const a = await call('POST', '/auth/login', { body: { email: 'ngo1@test.io', password: 'password123' } });
  const b = await call('POST', '/auth/login', { body: { email: 'ngo2@test.io', password: 'password123' } });
  assert.strictEqual(a.status, 200);
  assert.strictEqual(b.status, 200);
  ctx.ngo1 = a.json.token;
  ctx.ngo2 = b.json.token;
});

// ---------------- Donation + requests ----------------
step('donor creates a donation', async () => {
  const start = new Date(Date.now() + 60_000);
  const end = new Date(Date.now() + 3 * 3600_000);
  const r = await call('POST', '/donations', {
    token: ctx.donor,
    body: {
      title: 'Veg biryani', description: 'Fresh', portions: 10,
      pickupWindowStart: start.toISOString(), pickupWindowEnd: end.toISOString(),
      expiresAt: new Date(end.getTime() + 3600_000).toISOString(),
      foodCategory: 'cooked_meal', dietType: 'veg',
      address: { locality: 'Ameerpet' },
    },
  });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  ctx.donation = r.json.donation._id;
});

step('donation stores expiry, category and diet', async () => {
  const r = await call('GET', `/donations/${ctx.donation}`, { token: ctx.donor });
  assert.strictEqual(r.status, 200);
  assert.ok(r.json.expiresAt);
  assert.strictEqual(r.json.foodCategory, 'cooked_meal');
  assert.strictEqual(r.json.dietType, 'veg');
});

step('donation validation: expiry required, after pickup, valid category', async () => {
  const start = new Date(Date.now() + 60_000);
  const end = new Date(Date.now() + 3600_000);
  const base = {
    title: 'Rice', portions: 2, address: { locality: 'X' },
    pickupWindowStart: start.toISOString(), pickupWindowEnd: end.toISOString(),
  };
  const noExpiry = await call('POST', '/donations', { token: ctx.donor, body: base });
  assert.strictEqual(noExpiry.status, 400);
  const early = await call('POST', '/donations', {
    token: ctx.donor, body: { ...base, expiresAt: start.toISOString() },
  });
  assert.strictEqual(early.status, 400);
  assert.match(early.json.message, /safe to eat/);
  const badCat = await call('POST', '/donations', {
    token: ctx.donor, body: { ...base, expiresAt: end.toISOString(), foodCategory: 'rocks' },
  });
  assert.strictEqual(badCat.status, 400);
  const badDiet = await call('POST', '/donations', {
    token: ctx.donor, body: { ...base, expiresAt: end.toISOString(), dietType: 'meat' },
  });
  assert.strictEqual(badDiet.status, 400);
});

step('donation with photo (multipart) stores imageUrl', async () => {
  const start = new Date(Date.now() + 60_000);
  const end = new Date(Date.now() + 3600_000);
  const f = new FormData();
  f.append('title', 'Samosas');
  f.append('portions', '5');
  f.append('pickupWindowStart', start.toISOString());
  f.append('pickupWindowEnd', end.toISOString());
  f.append('expiresAt', end.toISOString());
  f.append('foodCategory', 'bakery');
  f.append('address', JSON.stringify({ locality: 'Begumpet' }));
  f.append('image', pngBlob(), 'food.png');
  const r = await call('POST', '/donations', { token: ctx.donor, form: f });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  assert.match(r.json.donation.imageUrl, /food-donations/);
  assert.strictEqual(r.json.donation.foodCategory, 'bakery');
  ctx.photoDonation = r.json.donation._id;
});

step('wrong photo type returns 400 with a clear message', async () => {
  const f = new FormData();
  f.append('title', 'Bad');
  f.append('image', new Blob(['hello'], { type: 'text/plain' }), 'x.txt');
  const r = await call('POST', '/donations', { token: ctx.donor, form: f });
  assert.strictEqual(r.status, 400);
  assert.match(r.json.message, /JPG, PNG and WEBP/);
});

step('NGO feed search treats special characters as text', async () => {
  const r = await call('GET', '/donations?search=' + encodeURIComponent('(((a+)+)+)$'), { token: ctx.ngo1 });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.count, 0);
  const ok = await call('GET', '/donations?search=biry', { token: ctx.ngo1 });
  assert.strictEqual(ok.json.count, 1);
  assert.ok(ok.json.donations[0].expiresAt);
});

step('NGO1 requests 6 portions -> pending_donor', async () => {
  const r = await call('POST', `/donations/${ctx.donation}/request`, { token: ctx.ngo1, body: { portions: 6 } });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  assert.strictEqual(r.json.allocation.status, 'pending_donor');
  ctx.a1 = r.json.allocation._id;
});

step('NGO2 requests 8 portions -> queued', async () => {
  const r = await call('POST', `/donations/${ctx.donation}/request`, { token: ctx.ngo2, body: { portions: 8 } });
  assert.strictEqual(r.status, 201);
  assert.strictEqual(r.json.allocation.status, 'queued');
  ctx.a2 = r.json.allocation._id;
});

step('donor sees both requests (no pickup codes)', async () => {
  const r = await call('GET', '/donations/my-donor-allocations', { token: ctx.donor });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.count, 2);
  for (const a of r.json.allocations) assert.strictEqual(a.pickupCode, undefined);
});

step('NGO cannot approve its own request', async () => {
  const r = await call('POST', `/donations/allocations/${ctx.a1}/approve`, { token: ctx.ngo1 });
  assert.strictEqual(r.status, 403);
});

step('approval requires full address and valid phone', async () => {
  const none = await call('POST', `/donations/allocations/${ctx.a1}/approve`, { token: ctx.donor, body: {} });
  assert.strictEqual(none.status, 400);
  const badPhone = await call('POST', `/donations/allocations/${ctx.a1}/approve`, {
    token: ctx.donor, body: { pickupAddress: 'Flat 4, Green Towers, Ameerpet', contactPhone: '12ab' },
  });
  assert.strictEqual(badPhone.status, 400);
  assert.match(badPhone.json.message, /phone/);
  const shortAddr = await call('POST', `/donations/allocations/${ctx.a1}/approve`, {
    token: ctx.donor, body: { pickupAddress: 'Ameerpet', contactPhone: '9876543210' },
  });
  assert.strictEqual(shortAddr.status, 400);
  const badLoc = await call('POST', `/donations/allocations/${ctx.a1}/approve`, {
    token: ctx.donor,
    body: { pickupAddress: 'Flat 4, Green Towers, Ameerpet', contactPhone: '9876543210', pickupLatitude: 95, pickupLongitude: 78.4 },
  });
  assert.strictEqual(badLoc.status, 400);
  const halfLoc = await call('POST', `/donations/allocations/${ctx.a1}/approve`, {
    token: ctx.donor,
    body: { pickupAddress: 'Flat 4, Green Towers, Ameerpet', contactPhone: '9876543210', pickupLatitude: 17.43 },
  });
  assert.strictEqual(halfLoc.status, 400);
  // Nothing was approved by the failed attempts.
  const n1 = await call('GET', '/donations/my-allocations', { token: ctx.ngo1 });
  assert.strictEqual(n1.json.allocations.find((a) => a._id === ctx.a1).status, 'pending_donor');
});

step('NGO2 cannot see pickup details before it is approved', async () => {
  const n2 = await call('GET', '/donations/my-allocations', { token: ctx.ngo2 });
  for (const a of n2.json.allocations) {
    assert.strictEqual(a.pickupAddress, null);
    assert.strictEqual(a.contactPhone, null);
  }
});

step('donor approves NGO1 -> NGO2 gets reduced offer of 4', async () => {
  const r = await call('POST', `/donations/allocations/${ctx.a1}/approve`, {
    token: ctx.donor,
    body: {
      pickupAddress: 'Flat 4, Green Towers, Ameerpet, Hyderabad',
      contactPhone: '98765 43210',
      pickupLatitude: 17.4375,
      pickupLongitude: 78.4482,
    },
  });
  assert.strictEqual(r.status, 200, JSON.stringify(r.json));
  assert.strictEqual(r.json.allocation.allocatedPortions, 6);
  const n2 = await call('GET', '/donations/my-allocations', { token: ctx.ngo2 });
  const mine = n2.json.allocations.find((a) => a._id === ctx.a2);
  assert.strictEqual(mine.status, 'awaiting_ngo_confirmation');
  assert.strictEqual(mine.offeredPortions, 4);
  // populated donation now includes donorName/remainingPortions
  assert.strictEqual(mine.donationId.donorName, 'Donor One');
  assert.strictEqual(mine.donationId.remainingPortions, 4);
});

step('NGO1 sees its pickup code', async () => {
  const r = await call('GET', '/donations/my-allocations', { token: ctx.ngo1 });
  const mine = r.json.allocations.find((a) => a._id === ctx.a1);
  assert.match(mine.pickupCode, /^\d{6}$/);
  ctx.code1 = mine.pickupCode;
  assert.strictEqual(mine.pickupAddress, 'Flat 4, Green Towers, Ameerpet, Hyderabad');
  assert.strictEqual(mine.contactPhone, '9876543210');
  assert.strictEqual(mine.contactName, 'Donor One');
  assert.strictEqual(mine.pickupLatitude, 17.4375);
  assert.strictEqual(mine.pickupLongitude, 78.4482);
  // The other NGO never sees NGO1's pickup details.
  const n2 = await call('GET', '/donations/my-allocations', { token: ctx.ngo2 });
  assert.ok(n2.json.allocations.every((a) => a._id !== ctx.a1));
});

step('NGO2 accepts reduced offer, donor rejects it', async () => {
  const c = await call('POST', `/donations/allocations/${ctx.a2}/confirm-offer`, { token: ctx.ngo2, body: { accept: true } });
  assert.strictEqual(c.status, 200);
  assert.strictEqual(c.json.allocation.status, 'pending_donor');
  const r = await call('POST', `/donations/allocations/${ctx.a2}/reject`, { token: ctx.donor });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.allocation.status, 'rejected');
});

step('wrong pickup code fails, right code collects', async () => {
  const wrong = ctx.code1 === '000000' ? '111111' : '000000';
  const bad = await call('POST', `/donations/allocations/${ctx.a1}/verify-pickup`, { token: ctx.donor, body: { code: wrong } });
  assert.strictEqual(bad.status, 400);
  const ok = await call('POST', `/donations/allocations/${ctx.a1}/verify-pickup`, { token: ctx.donor, body: { code: ctx.code1 } });
  assert.strictEqual(ok.status, 200, JSON.stringify(ok.json));
  assert.strictEqual(ok.json.allocation.status, 'collected');
});

step('donation with collected allocation cannot be cancelled', async () => {
  const r = await call('PATCH', `/donations/${ctx.donation}/cancel`, { token: ctx.donor });
  assert.strictEqual(r.status, 409);
});

step('a fresh donation can be cancelled by its donor only', async () => {
  const end = new Date(Date.now() + 3600_000);
  const d = await call('POST', '/donations', {
    token: ctx.donor,
    body: { title: 'Bread', portions: 3, pickupWindowStart: new Date().toISOString(), pickupWindowEnd: end.toISOString(), expiresAt: end.toISOString(), address: { locality: 'Kukatpally' } },
  });
  const notMine = await call('PATCH', `/donations/${d.json.donation._id}/cancel`, { token: ctx.ngo1 });
  assert.strictEqual(notMine.status, 403);
  const r = await call('PATCH', `/donations/${d.json.donation._id}/cancel`, { token: ctx.donor });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.donation.status, 'cancelled');
});

// ---------------- Admin overview ----------------
step('admin stats reflect the activity', async () => {
  const r = await call('GET', '/admin/stats', { token: ctx.admin });
  assert.strictEqual(r.status, 200, JSON.stringify(r.json));
  assert.strictEqual(r.json.users.donors, 1);
  assert.strictEqual(r.json.users.ngosVerified, 2);
  assert.strictEqual(r.json.users.ngosRejected, 1);
  assert.strictEqual(r.json.donations.total, 3);
  assert.strictEqual(r.json.donations.cancelled, 1);
  assert.strictEqual(r.json.requests.collected, 1);
  assert.strictEqual(r.json.portionsServed, 6);
});

step('admin lists users, donations and activity without secrets', async () => {
  const u = await call('GET', '/admin/users', { token: ctx.admin });
  assert.strictEqual(u.status, 200);
  assert.strictEqual(u.json.count, 4); // donor + 3 NGOs, admin excluded
  for (const x of u.json.users) assert.strictEqual(x.password, undefined);
  const d = await call('GET', '/admin/donations', { token: ctx.admin });
  assert.strictEqual(d.json.count, 3);
  const a = await call('GET', '/admin/activity', { token: ctx.admin });
  assert.strictEqual(a.json.count, 2);
  for (const x of a.json.allocations) {
    assert.strictEqual(x.pickupCode, undefined);
    assert.strictEqual(x.contactPhone, undefined);
    assert.strictEqual(x.pickupAddress, undefined);
    assert.strictEqual(x.pickupLatitude, undefined);
  }
  const bad = await call('GET', '/admin/ngos?status=weird', { token: ctx.admin });
  assert.strictEqual(bad.status, 400);
});

// ---------------- Alerts (in-app notifications) ----------------
const alertTypes = async (token) => {
  const r = await call('GET', '/notifications', { token });
  assert.strictEqual(r.status, 200, JSON.stringify(r.json));
  return { list: r.json.notifications, unread: r.json.unreadCount, types: r.json.notifications.map((n) => n.type) };
};

step('donor got an alert for each request to review', async () => {
  const { types, unread } = await alertTypes(ctx.donor);
  assert.deepStrictEqual(types.filter((t) => t === 'request_to_review').length, 2);
  assert.strictEqual(unread, types.length);
});

step('NGOs get alerts for verification, offers, approval, rejection and pickup', async () => {
  const n1 = await alertTypes(ctx.ngo1);
  for (const t of ['ngo_verified', 'request_approved', 'pickup_completed']) {
    assert.ok(n1.types.includes(t), `NGO1 missing ${t}: ${n1.types}`);
  }
  assert.ok(!n1.types.includes('reduced_offer'));
  const n2 = await alertTypes(ctx.ngo2);
  for (const t of ['ngo_verified', 'reduced_offer', 'request_rejected']) {
    assert.ok(n2.types.includes(t), `NGO2 missing ${t}: ${n2.types}`);
  }
  assert.ok(!n2.types.includes('request_approved'));
  // Newest first.
  const times = n2.list.map((n) => new Date(n.createdAt).getTime());
  assert.deepStrictEqual(times, [...times].sort((a, b) => b - a));
});

step('alerts can be marked read only by their owner', async () => {
  const { list } = await alertTypes(ctx.ngo1);
  const id = list[0]._id;
  const other = await call('PATCH', `/notifications/${id}/read`, { token: ctx.ngo2 });
  assert.strictEqual(other.status, 404);
  const bad = await call('PATCH', '/notifications/not-an-id/read', { token: ctx.ngo1 });
  assert.strictEqual(bad.status, 400);
  const ok = await call('PATCH', `/notifications/${id}/read`, { token: ctx.ngo1 });
  assert.strictEqual(ok.status, 200);
  assert.strictEqual(ok.json.notification.read, true);
  const all = await call('POST', '/notifications/read-all', { token: ctx.ngo1 });
  assert.strictEqual(all.status, 200);
  assert.strictEqual((await alertTypes(ctx.ngo1)).unread, 0);
  const noAuth = await call('GET', '/notifications', {});
  assert.strictEqual(noAuth.status, 401);
});

// ---------------- Recurring donations ----------------
const template = (over = {}) => ({
  title: 'Hostel dinner leftovers',
  portions: 25,
  windowHours: 2,
  safeHours: 4,
  locality: 'Ameerpet',
  foodCategory: 'cooked_meal',
  dietType: 'veg',
  ...over,
});

step('only donors can use recurring donations', async () => {
  const r = await call('GET', '/recurring', { token: ctx.ngo1 });
  assert.strictEqual(r.status, 403);
});

step('recurring template validation', async () => {
  const unsafe = await call('POST', '/recurring', { token: ctx.donor, body: template({ safeHours: 1 }) });
  assert.strictEqual(unsafe.status, 400);
  assert.match(unsafe.json.message, /safe/);
  const noTitle = await call('POST', '/recurring', { token: ctx.donor, body: template({ title: ' ' }) });
  assert.strictEqual(noTitle.status, 400);
  const badCat = await call('POST', '/recurring', { token: ctx.donor, body: template({ foodCategory: 'pizza' }) });
  assert.strictEqual(badCat.status, 400);
});

step('donor creates a recurring template', async () => {
  const r = await call('POST', '/recurring', { token: ctx.donor, body: template() });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  assert.strictEqual(r.json.template.active, true);
  assert.strictEqual(r.json.template.confirmedToday, false);
  ctx.tpl1 = r.json.template._id;
});

step("confirming today posts a real donation, once per day", async () => {
  const r = await call('POST', `/recurring/${ctx.tpl1}/confirm`, { token: ctx.donor, body: { portions: 15 } });
  assert.strictEqual(r.status, 201, JSON.stringify(r.json));
  assert.strictEqual(r.json.template.confirmedToday, true);
  const d = r.json.donation;
  assert.strictEqual(d.portions, 15);
  assert.strictEqual(d.remainingPortions, 15);
  assert.strictEqual(d.status, 'available');
  assert.strictEqual(d.address.locality, 'Ameerpet');
  assert.strictEqual(d.foodCategory, 'cooked_meal');
  const windowMs = new Date(d.pickupWindowEnd) - new Date(d.pickupWindowStart);
  assert.strictEqual(windowMs, 2 * 3600 * 1000);
  assert.ok(new Date(d.expiresAt) >= new Date(d.pickupWindowEnd));
  ctx.recurringDonation = d._id;

  // NGOs see it like any other donation.
  const feed = await call('GET', '/donations', { token: ctx.ngo1 });
  assert.ok(JSON.stringify(feed.json).includes(d._id));

  const again = await call('POST', `/recurring/${ctx.tpl1}/confirm`, { token: ctx.donor, body: {} });
  assert.strictEqual(again.status, 409);
  const skip = await call('POST', `/recurring/${ctx.tpl1}/skip`, { token: ctx.donor });
  assert.strictEqual(skip.status, 409);
});

step('skipping today blocks confirming today', async () => {
  const c = await call('POST', '/recurring', { token: ctx.donor, body: template({ title: 'Bakery bread' }) });
  ctx.tpl2 = c.json.template._id;
  const s = await call('POST', `/recurring/${ctx.tpl2}/skip`, { token: ctx.donor });
  assert.strictEqual(s.status, 200);
  assert.strictEqual(s.json.template.skippedToday, true);
  const conf = await call('POST', `/recurring/${ctx.tpl2}/confirm`, { token: ctx.donor });
  assert.strictEqual(conf.status, 409);
});

step('paused templates cannot post; edit, list and delete work', async () => {
  const c = await call('POST', '/recurring', { token: ctx.donor, body: template({ title: 'Fruit' }) });
  const id = c.json.template._id;
  const pause = await call('PATCH', `/recurring/${id}`, { token: ctx.donor, body: { active: false } });
  assert.strictEqual(pause.status, 200);
  assert.strictEqual(pause.json.template.active, false);
  const conf = await call('POST', `/recurring/${id}/confirm`, { token: ctx.donor });
  assert.strictEqual(conf.status, 409);
  const badEdit = await call('PATCH', `/recurring/${id}`, { token: ctx.donor, body: { windowHours: 6 } });
  assert.strictEqual(badEdit.status, 400); // safeHours 4 < window 6
  const edit = await call('PATCH', `/recurring/${id}`, { token: ctx.donor, body: { portions: 40 } });
  assert.strictEqual(edit.json.template.portions, 40);

  const list = await call('GET', '/recurring', { token: ctx.donor });
  assert.strictEqual(list.json.count, 3);
  const del = await call('DELETE', `/recurring/${id}`, { token: ctx.donor });
  assert.strictEqual(del.status, 200);
  const after = await call('GET', '/recurring', { token: ctx.donor });
  assert.strictEqual(after.json.count, 2);
  const missing = await call('POST', `/recurring/${id}/confirm`, { token: ctx.donor });
  assert.strictEqual(missing.status, 404);
});

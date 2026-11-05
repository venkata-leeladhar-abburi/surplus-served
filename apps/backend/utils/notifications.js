const Notification = require('../models/Notification');
const Donation = require('../models/Donation');

// Alerts are a side effect: a failure here must never break the request
// that triggered it, so errors are logged and swallowed.
const createNotifications = async (entries) => {
  const valid = entries.filter((e) => e && e.userId);
  if (valid.length === 0) return;

  try {
    await Notification.insertMany(valid, { ordered: false });
  } catch (error) {
    console.error('Notification error:', error.message);
  }
};

const portionsOf = (allocation) =>
  allocation.allocatedPortions ||
  allocation.offeredPortions ||
  allocation.requestedPortions;

// Who gets told, and what, for each allocation event.
const ALLOCATION_MESSAGES = {
  // Donor: an NGO request now needs approve/reject.
  request_to_review: (a, title) => ({
    userId: a.donorId,
    title: 'New request to review',
    body: `${a.ngoName || 'An NGO'} wants ${portionsOf(a)} portion(s) of "${title}".`,
  }),
  // NGO: fewer portions are left than requested.
  reduced_offer: (a, title) => ({
    userId: a.ngoId,
    title: 'Fewer portions left',
    body: `Only ${a.offeredPortions} of the ${a.requestedPortions} portions of "${title}" are left. Accept or decline in My Requests.`,
  }),
  request_approved: (a, title) => ({
    userId: a.ngoId,
    title: 'Request approved',
    body: `The donor approved ${portionsOf(a)} portion(s) of "${title}". Pickup address, contact and code are in My Requests.`,
  }),
  request_rejected: (a, title) => ({
    userId: a.ngoId,
    title: 'Request not approved',
    body: `The donor did not approve your request for "${title}".`,
  }),
  request_closed: (a, title) => ({
    userId: a.ngoId,
    title: 'Request closed',
    body: `"${title}" is no longer available, so your request was closed.`,
  }),
  pickup_completed: (a, title) => ({
    userId: a.ngoId,
    title: 'Pickup confirmed',
    body: `Collection of ${portionsOf(a)} portion(s) of "${title}" is complete. Thank you!`,
  }),
};

// Notify about one or more allocations of the same donation.
const notifyAllocations = async (allocations, type) => {
  const list = (Array.isArray(allocations) ? allocations : [allocations])
    .filter(Boolean);
  if (list.length === 0) return;

  const build = ALLOCATION_MESSAGES[type];
  if (!build) return;

  try {
    const donationIds = [...new Set(list.map((a) => String(a.donationId)))];
    const donations = await Donation.find({ _id: { $in: donationIds } })
      .select('title')
      .lean();
    const titles = new Map(donations.map((d) => [String(d._id), d.title]));

    await createNotifications(
      list.map((a) => ({
        ...build(a, titles.get(String(a.donationId)) || 'a donation'),
        type,
        donationId: a.donationId,
        allocationId: a._id,
      }))
    );
  } catch (error) {
    console.error('Notification error:', error.message);
  }
};

module.exports = {
  createNotifications,
  notifyAllocations,
};

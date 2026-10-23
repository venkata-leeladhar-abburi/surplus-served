const Donation = require('../models/Donation');

// POST /api/donations - Create a donation securely using authenticated user info
exports.createDonation = async (req, res) => {
  try {
    const {
      title,
      description,
      portions,
      pickupWindowStart,
      pickupWindowEnd,
      address,
    } = req.body;

    // Pull verified user identity attached by auth middleware (e.g., req.user)
    // Fallback to body values if auth middleware isn't attached during development phase
    const donorId = req.user?._id || req.user?.id || req.body.donorId;
    const donorName = req.user?.name || req.body.donorName;

    if (!donorId) {
      return res.status(400).json({ message: 'Donor ID is required.' });
    }

    const donation = new Donation({
      donorId,
      donorName,
      title,
      description,
      portions,
      pickupWindowStart,
      pickupWindowEnd,
      address,
    });

    await donation.save();
    return res.status(201).json(donation);
  } catch (error) {
    console.error('Error creating donation:', error);
    return res.status(500).json({ message: 'Server error creating donation' });
  }
};

// GET /api/donations - Get all donations (optional filter by donorId)
exports.getDonations = async (req, res) => {
  try {
    const { donorId } = req.query;
    const filter = {};

    if (donorId) {
      filter.donorId = donorId;
    }

    const donations = await Donation.find(filter).sort({ createdAt: -1 });
    return res.status(200).json(donations);
  } catch (error) {
    console.error('Error fetching donations:', error);
    return res.status(500).json({ message: 'Server error fetching donations' });
  }
};

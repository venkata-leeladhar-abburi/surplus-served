
const Donation = require('../models/Donation');
const Allocation = require('../models/Allocation');

// Donor dashboard statistics
exports.getDonorDashboard = async (req, res) => {
  try {
    const donorId = req.user._id;

    const [total, available, claimed, collected, cancelled] =
      await Promise.all([
        Donation.countDocuments({ donorId }),
        Donation.countDocuments({ donorId, status: 'available' }),
        Donation.countDocuments({ donorId, status: 'claimed' }),
        Donation.countDocuments({ donorId, status: 'collected' }),
        Donation.countDocuments({ donorId, status: 'cancelled' }),
      ]);

    return res.status(200).json({
      total,
      available,
      claimed,
      collected,
      cancelled,
    });
  } catch (error) {
    console.error('Donor dashboard error:', error);
    return res.status(500).json({
      message: 'Unable to fetch donor dashboard statistics.',
    });
  }
};

// NGO dashboard statistics
exports.getNgoDashboard = async (req, res) => {
  try {
    const ngoId = req.user._id;

    const [total, queued, awaitingConfirmation, pendingDonor, approved, collected] =
      await Promise.all([
        Allocation.countDocuments({ ngoId }),
        Allocation.countDocuments({ ngoId, status: 'queued' }),
        Allocation.countDocuments({
          ngoId,
          status: 'awaiting_ngo_confirmation',
        }),
        Allocation.countDocuments({ ngoId, status: 'pending_donor' }),
        Allocation.countDocuments({ ngoId, status: 'approved' }),
        Allocation.countDocuments({ ngoId, status: 'collected' }),
      ]);

    return res.status(200).json({
      total,
      queued,
      awaitingConfirmation,
      pendingDonor,
      approved,
      collected,
    });
  } catch (error) {
    console.error('NGO dashboard error:', error);
    return res.status(500).json({
      message: 'Unable to fetch NGO dashboard statistics.',
    });
  }
};

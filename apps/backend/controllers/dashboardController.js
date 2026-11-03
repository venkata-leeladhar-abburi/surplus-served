const Donation = require('../models/Donation');

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

// Receiver dashboard statistics
exports.getReceiverDashboard = async (req, res) => {
  try {
    const receiverId = req.user._id;

    const [total, claimed, collected] = await Promise.all([
      Donation.countDocuments({ allocatedToNgoId: receiverId }),
      Donation.countDocuments({
        allocatedToNgoId: receiverId,
        status: 'claimed',
      }),
      Donation.countDocuments({
        allocatedToNgoId: receiverId,
        status: 'collected',
      }),
    ]);

    return res.status(200).json({
      total,
      claimed,
      collected,
    });
  } catch (error) {
    console.error('Receiver dashboard error:', error);
    return res.status(500).json({
      message: 'Unable to fetch receiver dashboard statistics.',
    });
  }
};

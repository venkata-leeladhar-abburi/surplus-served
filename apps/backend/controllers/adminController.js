
const mongoose = require('mongoose');
const User = require('../models/User');
const Donation = require('../models/Donation');
const Allocation = require('../models/Allocation');

const NGO_LIST_FIELDS =
  'name email ngoDetails.organizationName ngoDetails.registrationNumber ' +
  'ngoDetails.documentUrl ngoDetails.verificationStatus ' +
  'ngoDetails.rejectionReason createdAt updatedAt';

// GET /api/admin/ngos/pending
// Fetch all NGOs awaiting verification.
exports.getPendingNGOs = async (req, res) => {
  try {
    const ngos = await User.find({
      role: 'ngo',
      'ngoDetails.verificationStatus': 'pending',
    })
      .select('name email ngoDetails.organizationName ngoDetails.registrationNumber ngoDetails.documentUrl createdAt')
      .sort({ createdAt: 1 });

    return res.status(200).json({
      count: ngos.length,
      ngos,
    });
  } catch (error) {
    console.error('Fetch pending NGOs error:', error);

    return res.status(500).json({
      message: 'Unable to fetch pending NGO applications.',
    });
  }
};

// PATCH /api/admin/ngos/:id/approve
// Approve a pending NGO application.
exports.approveNGO = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid NGO ID.',
      });
    }

    const ngo = await User.findOneAndUpdate(
      {
        _id: id,
        role: 'ngo',
        'ngoDetails.verificationStatus': 'pending',
      },
      {
        $set: {
          'ngoDetails.verificationStatus': 'verified',
          'ngoDetails.rejectionReason': null,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    ).select('-password');

    if (!ngo) {
      return res.status(404).json({
        message: 'Pending NGO application not found.',
      });
    }

    return res.status(200).json({
      message: 'NGO successfully verified.',
      ngo,
    });
  } catch (error) {
    console.error('Approve NGO error:', error);

    return res.status(500).json({
      message: 'Unable to approve NGO application.',
    });
  }
};

// PATCH /api/admin/ngos/:id/reject
// Reject a pending NGO application with a reason.
exports.rejectNGO = async (req, res) => {
  try {
    const { id } = req.params;
    const reason =
      typeof req.body.reason === 'string'
        ? req.body.reason.trim()
        : '';

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid NGO ID.',
      });
    }

    if (!reason) {
      return res.status(400).json({
        message: 'A rejection reason is required.',
      });
    }

    const ngo = await User.findOneAndUpdate(
      {
        _id: id,
        role: 'ngo',
        'ngoDetails.verificationStatus': 'pending',
      },
      {
        $set: {
          'ngoDetails.verificationStatus': 'rejected',
          'ngoDetails.rejectionReason': reason,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    ).select('-password');

    if (!ngo) {
      return res.status(404).json({
        message: 'Pending NGO application not found.',
      });
    }

    return res.status(200).json({
      message: 'NGO application rejected.',
      ngo,
    });
  } catch (error) {
    console.error('Reject NGO error:', error);

    return res.status(500).json({
      message: 'Unable to reject NGO application.',
    });
  }
};

// GET /api/admin/ngos?status=pending|verified|rejected
// List NGOs, optionally filtered by verification status.
exports.getNGOs = async (req, res) => {
  try {
    const { status } = req.query;
    const allowedStatuses = ['pending', 'verified', 'rejected'];

    const filter = { role: 'ngo' };

    if (status) {
      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({
          message: 'Invalid verification status.',
          allowedStatuses,
        });
      }

      filter['ngoDetails.verificationStatus'] = status;
    }

    const ngos = await User.find(filter)
      .select(NGO_LIST_FIELDS)
      .sort({ createdAt: -1 });

    return res.status(200).json({
      count: ngos.length,
      ngos,
    });
  } catch (error) {
    console.error('Fetch NGOs error:', error);

    return res.status(500).json({
      message: 'Unable to fetch NGOs.',
    });
  }
};

// GET /api/admin/stats
// Platform overview counts for the admin dashboard.
exports.getStats = async (req, res) => {
  try {
    const [
      donors,
      ngosPending,
      ngosVerified,
      ngosRejected,
      donationsTotal,
      donationsAvailable,
      donationsClaimed,
      donationsCollected,
      donationsCancelled,
      requestsActive,
      requestsCollected,
      servedAgg,
    ] = await Promise.all([
      User.countDocuments({ role: 'donor' }),
      User.countDocuments({ role: 'ngo', 'ngoDetails.verificationStatus': 'pending' }),
      User.countDocuments({ role: 'ngo', 'ngoDetails.verificationStatus': 'verified' }),
      User.countDocuments({ role: 'ngo', 'ngoDetails.verificationStatus': 'rejected' }),
      Donation.countDocuments({}),
      Donation.countDocuments({ status: 'available' }),
      Donation.countDocuments({ status: 'claimed' }),
      Donation.countDocuments({ status: 'collected' }),
      Donation.countDocuments({ status: 'cancelled' }),
      Allocation.countDocuments({
        status: { $in: ['queued', 'awaiting_ngo_confirmation', 'pending_donor', 'approved'] },
      }),
      Allocation.countDocuments({ status: 'collected' }),
      Allocation.aggregate([
        { $match: { status: 'collected' } },
        { $group: { _id: null, total: { $sum: '$allocatedPortions' } } },
      ]),
    ]);

    return res.status(200).json({
      users: {
        donors,
        ngosPending,
        ngosVerified,
        ngosRejected,
      },
      donations: {
        total: donationsTotal,
        available: donationsAvailable,
        claimed: donationsClaimed,
        collected: donationsCollected,
        cancelled: donationsCancelled,
      },
      requests: {
        active: requestsActive,
        collected: requestsCollected,
      },
      portionsServed: servedAgg[0]?.total || 0,
    });
  } catch (error) {
    console.error('Admin stats error:', error);

    return res.status(500).json({
      message: 'Unable to fetch platform statistics.',
    });
  }
};

// GET /api/admin/users?role=donor|ngo
// List donor and NGO accounts (never returns passwords).
exports.getUsers = async (req, res) => {
  try {
    const { role } = req.query;

    const filter = { role: { $in: ['donor', 'ngo'] } };

    if (role) {
      if (!['donor', 'ngo'].includes(role)) {
        return res.status(400).json({
          message: 'Invalid role filter.',
        });
      }

      filter.role = role;
    }

    const users = await User.find(filter)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(200);

    return res.status(200).json({
      count: users.length,
      users,
    });
  } catch (error) {
    console.error('Admin users error:', error);

    return res.status(500).json({
      message: 'Unable to fetch users.',
    });
  }
};

// GET /api/admin/donations?status=available|claimed|collected|cancelled
// Recent donations across all donors.
exports.getDonations = async (req, res) => {
  try {
    const { status } = req.query;
    const allowedStatuses = ['available', 'claimed', 'collected', 'cancelled'];

    const filter = {};

    if (status) {
      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({
          message: 'Invalid donation status.',
          allowedStatuses,
        });
      }

      filter.status = status;
    }

    const donations = await Donation.find(filter)
      .sort({ createdAt: -1 })
      .limit(200);

    return res.status(200).json({
      count: donations.length,
      donations,
    });
  } catch (error) {
    console.error('Admin donations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch donations.',
    });
  }
};

// GET /api/admin/activity
// Most recent donation requests across the platform (pickup codes hidden).
exports.getActivity = async (req, res) => {
  try {
    const allocations = await Allocation.find({})
      // Donor phone/address are only for the matched NGO.
      .select('-pickupAddress -contactName -contactPhone')
      .populate('donationId', 'title donorName address')
      .sort({ updatedAt: -1 })
      .limit(50);

    return res.status(200).json({
      count: allocations.length,
      allocations,
    });
  } catch (error) {
    console.error('Admin activity error:', error);

    return res.status(500).json({
      message: 'Unable to fetch platform activity.',
    });
  }
};

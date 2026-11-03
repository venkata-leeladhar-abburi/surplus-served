
const User = require('../models/User');

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

    if (!require('mongoose').Types.ObjectId.isValid(id)) {
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

    if (!require('mongoose').Types.ObjectId.isValid(id)) {
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

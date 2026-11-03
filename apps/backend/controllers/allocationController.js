
const crypto = require('crypto');
const mongoose = require('mongoose');
const Donation = require('../models/Donation');

// Request and allocate a donation.
// The first valid request wins through an atomic MongoDB update.
exports.requestDonation = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    const receiver = req.user;
    const pickupCode = String(crypto.randomInt(1000, 10000));

    const donation = await Donation.findOneAndUpdate(
      {
        _id: id,
        status: 'available',
        pickupWindowEnd: { $gt: new Date() },
        donorId: { $ne: receiver._id },
      },
      {
        $set: {
          status: 'claimed',
          allocatedToNgoId: receiver._id,
          allocatedToNgoName: receiver.name,
          pickupCode,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!donation) {
      const existing = await Donation.findById(id);

      if (!existing) {
        return res.status(404).json({
          message: 'Donation not found.',
        });
      }

      if (
        String(existing.allocatedToNgoId) ===
        String(receiver._id)
      ) {
        return res.status(200).json({
          message: 'You have already been allocated this donation.',
          donation: {
            _id: existing._id,
            title: existing.title,
            status: existing.status,
          },
        });
      }

      return res.status(409).json({
        message: 'This donation is no longer available.',
      });
    }

    return res.status(200).json({
      message: 'Donation successfully allocated to you.',
      donation: {
        _id: donation._id,
        title: donation.title,
        status: donation.status,
        allocatedToNgoName: donation.allocatedToNgoName,
        pickupWindowStart: donation.pickupWindowStart,
        pickupWindowEnd: donation.pickupWindowEnd,
      },
    });
  } catch (error) {
    console.error('Donation allocation error:', error);

    return res.status(500).json({
      message: 'Unable to request donation.',
    });
  }
};

// GET /api/donations/my-allocations
// Fetch receiver history with optional status filtering.
exports.getMyAllocations = async (req, res) => {
  try {
    const { status } = req.query;

    const allowedStatuses = [
      'available',
      'claimed',
      'collected',
      'cancelled',
    ];

    if (status && !allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: 'Invalid donation status filter.',
        allowedStatuses,
      });
    }

    const filter = {
      allocatedToNgoId: req.user._id,
    };

    if (status) {
      filter.status = status;
    }

    const donations = await Donation.find(filter)
      .select('-pickupCode')
      .sort({ updatedAt: -1 });

    return res.status(200).json({
      count: donations.length,
      donations,
    });
  } catch (error) {
    console.error('Fetch allocations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch your allocation history.',
    });
  }
};

// POST /api/donations/:id/verify-pickup
// Verify pickup code and complete the donation.
exports.verifyPickupCode = async (req, res) => {
  try {
    const { id } = req.params;
    const code = String(req.body.code || '').trim();

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    if (!/^\d{4}$/.test(code)) {
      return res.status(400).json({
        message: 'Enter a valid 4-digit pickup code.',
      });
    }

    const donation = await Donation.findOne({
      _id: id,
      allocatedToNgoId: req.user._id,
      status: 'claimed',
    }).select('+pickupCode');

    if (!donation) {
      return res.status(404).json({
        message: 'No active allocation found.',
      });
    }

    if (donation.pickupCode !== code) {
      return res.status(400).json({
        message: 'Incorrect pickup code.',
      });
    }

    const updatedDonation = await Donation.findOneAndUpdate(
      {
        _id: id,
        allocatedToNgoId: req.user._id,
        status: 'claimed',
        pickupCode: code,
      },
      {
        $set: {
          status: 'collected',
          collectedAt: new Date(),
          pickupCode: null,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!updatedDonation) {
      return res.status(409).json({
        message: 'Donation has already been collected or changed.',
      });
    }

    return res.status(200).json({
      message: 'Food collection confirmed successfully.',
      donation: {
        _id: updatedDonation._id,
        title: updatedDonation.title,
        status: updatedDonation.status,
        collectedAt: updatedDonation.collectedAt,
      },
    });
  } catch (error) {
    console.error('Pickup verification error:', error);

    return res.status(500).json({
      message: 'Unable to verify pickup code.',
    });
  }
};

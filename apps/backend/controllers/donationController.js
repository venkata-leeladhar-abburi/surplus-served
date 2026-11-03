
const mongoose = require('mongoose');
const Donation = require('../models/Donation');

// POST /api/donations
// Create a donation using the authenticated donor's identity
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

    if (
      typeof title !== 'string' ||
      !title.trim() ||
      !Number.isInteger(portions) ||
      portions < 1 ||
      !pickupWindowStart ||
      !pickupWindowEnd ||
      !address ||
      typeof address.locality !== 'string' ||
      !address.locality.trim()
    ) {
      return res.status(400).json({
        message: 'Please provide all required donation details.',
      });
    }

    const start = new Date(pickupWindowStart);
    const end = new Date(pickupWindowEnd);

    if (
      Number.isNaN(start.getTime()) ||
      Number.isNaN(end.getTime()) ||
      end <= start ||
      end <= new Date()
    ) {
      return res.status(400).json({
        message: 'Please provide a valid future pickup window.',
      });
    }

    const donation = await Donation.create({
      donorId: req.user._id,
      donorName: req.user.name,
      title: title.trim(),
      description:
        typeof description === 'string'
          ? description.trim()
          : null,
      portions,
      pickupWindowStart: start,
      pickupWindowEnd: end,
      address: {
        locality: address.locality.trim(),
      },
      status: 'available',
    });

    return res.status(201).json({
      message: 'Donation created successfully.',
      donation,
    });
  } catch (error) {
    console.error('Create donation error:', error);

    return res.status(500).json({
      message: 'Unable to create donation.',
    });
  }
};

// GET /api/donations
// Fetch available donations for receivers
exports.getDonations = async (req, res) => {
  try {
    const donations = await Donation.find({
      status: 'available',
      pickupWindowEnd: { $gt: new Date() },
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      count: donations.length,
      donations,
    });
  } catch (error) {
    console.error('Fetch donations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch donations.',
    });
  }
};

// GET /api/donations/mine
// Fetch donations created by the logged-in donor
exports.getMyDonations = async (req, res) => {
  try {
    const donations = await Donation.find({
      donorId: req.user._id,
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      count: donations.length,
      donations,
    });
  } catch (error) {
    console.error('Fetch donor donations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch your donations.',
    });
  }
};

// GET /api/donations/:id
// Fetch donation details; pickup code is visible only to its original donor
exports.getDonationById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    let donation = await Donation.findById(id);

    if (!donation) {
      return res.status(404).json({
        message: 'Donation not found.',
      });
    }

    // Only the original donor can retrieve the pickup code.
    if (
      req.user.role === 'donor' &&
      String(donation.donorId) === String(req.user._id)
    ) {
      donation = await Donation.findById(id).select('+pickupCode');
    }

    return res.status(200).json(donation);
  } catch (error) {
    console.error('Fetch donation details error:', error);

    return res.status(500).json({
      message: 'Unable to fetch donation details.',
    });
  }
};

// PATCH /api/donations/:id/cancel
// Only the original donor can cancel an available donation
exports.cancelDonation = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    const donation = await Donation.findOneAndUpdate(
      {
        _id: id,
        donorId: req.user._id,
        status: 'available',
      },
      {
        $set: { status: 'cancelled' },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (donation) {
      return res.status(200).json({
        message: 'Donation cancelled successfully.',
        donation,
      });
    }

    const existingDonation = await Donation.findOne({
      _id: id,
      donorId: req.user._id,
    });

    if (!existingDonation) {
      return res.status(404).json({
        message: 'Donation not found or you are not its owner.',
      });
    }

    return res.status(409).json({
      message: 'Only available donations can be cancelled.',
    });
  } catch (error) {
    console.error('Cancel donation error:', error);

    return res.status(500).json({
      message: 'Unable to cancel donation.',
    });
  }
};

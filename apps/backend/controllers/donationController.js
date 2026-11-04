
const mongoose = require('mongoose');
const Donation = require('../models/Donation');
const cloudinary = require('../config/cloudinary');

// POST /api/donations
// Create a donation with an optional food image
exports.createDonation = async (req, res) => {
  let uploadedImagePublicId = null;

  try {
    const {
      title,
      description,
      portions,
      pickupWindowStart,
      pickupWindowEnd,
      address,
    } = req.body;

    let parsedAddress = address;

    if (typeof address === 'string') {
      try {
        parsedAddress = JSON.parse(address);
      } catch (error) {
        return res.status(400).json({
          message: 'Invalid address format.',
        });
      }
    }

    const parsedPortions = Number(portions);

    if (
      typeof title !== 'string' ||
      !title.trim() ||
      !Number.isInteger(parsedPortions) ||
      parsedPortions < 1 ||
      !pickupWindowStart ||
      !pickupWindowEnd ||
      !parsedAddress ||
      typeof parsedAddress.locality !== 'string' ||
      !parsedAddress.locality.trim()
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

    let imageUrl = null;
    let imagePublicId = null;

    // Upload image to Cloudinary if provided
    if (req.file) {
      const uploadResult = await new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder: 'surplus-served/food-donations',
            resource_type: 'image',
          },
          (error, result) => {
            if (error) {
              reject(error);
            } else {
              resolve(result);
            }
          }
        );

        uploadStream.end(req.file.buffer);
      });

      imageUrl = uploadResult.secure_url;
      imagePublicId = uploadResult.public_id;
      uploadedImagePublicId = uploadResult.public_id;
    }

    const donation = await Donation.create({
      donorId: req.user._id,
      donorName: req.user.name,
      title: title.trim(),
      description:
        typeof description === 'string'
          ? description.trim()
          : null,
      portions: parsedPortions,

      // Initially, all portions are available
      remainingPortions: parsedPortions,

      pickupWindowStart: start,
      pickupWindowEnd: end,
      address: {
        locality: parsedAddress.locality.trim(),
      },
      imageUrl,
      imagePublicId,
      status: 'available',
    });

    return res.status(201).json({
      message: 'Donation created successfully.',
      donation,
    });
  } catch (error) {
    // Remove uploaded image if donation creation fails
    if (uploadedImagePublicId) {
      try {
        await cloudinary.uploader.destroy(uploadedImagePublicId);
      } catch (cleanupError) {
        console.error('Cloudinary cleanup error:', cleanupError);
      }
    }

    console.error('Create donation error:', error);

    return res.status(500).json({
      message: 'Unable to create donation.',
    });
  }
};

// GET /api/donations
// Fetch available donations with search and locality filters
exports.getDonations = async (req, res) => {
  try {
    const { search, locality } = req.query;

    const filter = {
      status: 'available',
      remainingPortions: { $gt: 0 },
      pickupWindowEnd: { $gt: new Date() },
    };

    if (search && search.trim()) {
      filter.title = {
        $regex: search.trim(),
        $options: 'i',
      };
    }

    if (locality && locality.trim()) {
      filter['address.locality'] = {
        $regex: locality.trim(),
        $options: 'i',
      };
    }

    const donations = await Donation.find(filter)
      .sort({ createdAt: -1 });

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
// Fetch donor history with optional status filtering
exports.getMyDonations = async (req, res) => {
  try {
    const { status } = req.query;

    const allowedStatuses = [
      'available',
      'claimed',
      'collected',
      'cancelled',
    ];

    const filter = {
      donorId: req.user._id,
    };

    if (status) {
      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({
          message: 'Invalid donation status.',
        });
      }

      filter.status = status;
    }

    const donations = await Donation.find(filter)
      .sort({ createdAt: -1 });

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
// Fetch donation details without exposing pickup codes
exports.getDonationById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    const donation = await Donation.findById(id);

    if (!donation) {
      return res.status(404).json({
        message: 'Donation not found.',
      });
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
// Only the original donor can cancel a donation
// Cancellation is allowed only before any portions are allocated
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
        remainingPortions: { $eq: '$portions' },
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
      message:
        'This donation cannot be cancelled because it may already have allocated portions or is no longer available.',
    });
  } catch (error) {
    console.error('Cancel donation error:', error);

    return res.status(500).json({
      message: 'Unable to cancel donation.',
    });
  }
};

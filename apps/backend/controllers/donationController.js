
const mongoose = require('mongoose');
const Donation = require('../models/Donation');
const Allocation = require('../models/Allocation');
const cloudinary = require('../config/cloudinary');

const FOOD_CATEGORIES = Donation.schema.path('foodCategory').enumValues;
const DIET_TYPES = ['veg', 'non_veg'];

// Escape user text before using it inside a MongoDB regex.
const escapeRegex = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

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
      expiresAt,
      foodCategory,
      dietType,
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

    // Food safety: the food must stay safe until the pickup window ends.
    const expiry = new Date(expiresAt);

    if (!expiresAt || Number.isNaN(expiry.getTime())) {
      return res.status(400).json({
        message: 'Please provide when the food expires (expiresAt).',
      });
    }

    if (expiry < end) {
      return res.status(400).json({
        message:
          'The food must stay safe to eat until the end of the pickup window.',
      });
    }

    const category =
      typeof foodCategory === 'string' && foodCategory.trim()
        ? foodCategory.trim()
        : 'other';

    if (!FOOD_CATEGORIES.includes(category)) {
      return res.status(400).json({
        message: 'Invalid food category.',
        allowedCategories: FOOD_CATEGORIES,
      });
    }

    const diet =
      typeof dietType === 'string' && dietType.trim()
        ? dietType.trim()
        : null;

    if (diet && !DIET_TYPES.includes(diet)) {
      return res.status(400).json({
        message: 'Invalid diet type. Use veg or non_veg.',
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
      expiresAt: expiry,
      foodCategory: category,
      dietType: diet,
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
    // Only verified NGOs can browse donations
    if (req.user.ngoDetails?.verificationStatus !== 'verified') {
      return res.status(403).json({
        message: 'Your NGO account is not verified.',
      });
    }

    const { search, locality } = req.query;

    const now = new Date();

    const filter = {
      status: 'available',
      remainingPortions: { $gt: 0 },
      pickupWindowEnd: { $gt: now },
      // Hide expired food. Older donations have no expiry recorded.
      $or: [{ expiresAt: null }, { expiresAt: { $gt: now } }],
    };

    if (typeof search === 'string' && search.trim()) {
      filter.title = {
        $regex: escapeRegex(search.trim()),
        $options: 'i',
      };
    }

    if (typeof locality === 'string' && locality.trim()) {
      filter['address.locality'] = {
        $regex: escapeRegex(locality.trim()),
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
    // Only verified NGOs can access donation details
    if (
      req.user.role === 'ngo' &&
      req.user.ngoDetails?.verificationStatus !== 'verified'
    ) {
      return res.status(403).json({
        message: 'Your NGO account is not verified.',
      });
    }

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
exports.cancelDonation = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    let cancelledDonation = null;

    await session.withTransaction(async () => {
      const donation = await Donation.findOne({
        _id: id,
        donorId: req.user._id,
      }).session(session);

      if (!donation) {
        throw new Error('DONATION_NOT_FOUND');
      }

      // Serialize cancellation with NGO request creation
      const lockResult = await Donation.updateOne(
        { _id: id },
        { $inc: { queueRevision: 1 } },
        { session }
      );

      if (lockResult.matchedCount !== 1) {
        throw new Error('DONATION_NOT_FOUND');
      }

      // Check for unresolved NGO allocations
      const activeAllocation = await Allocation.findOne({
        donationId: id,
        status: {
          $in: [
            'queued',
            'awaiting_ngo_confirmation',
            'pending_donor',
            'approved',
          ],
        },
      }).session(session);

      if (activeAllocation) {
        throw new Error('ACTIVE_ALLOCATIONS_EXIST');
      }

      // Do not allow cancellation after portions are allocated
      if (
        donation.status !== 'available' ||
        donation.remainingPortions !== donation.portions
      ) {
        throw new Error('DONATION_ALREADY_ALLOCATED');
      }

      cancelledDonation = await Donation.findOneAndUpdate(
        {
          _id: id,
          donorId: req.user._id,
          status: 'available',
          remainingPortions: donation.portions,
        },
        {
          $set: {
            status: 'cancelled',
          },
        },
        {
          new: true,
          session,
          runValidators: true,
        }
      );

      if (!cancelledDonation) {
        throw new Error('DONATION_STATUS_CHANGED');
      }
    });

    return res.status(200).json({
      message: 'Donation cancelled successfully.',
      donation: cancelledDonation,
    });

  } catch (error) {
    console.error('Cancel donation error:', error);

    if (error.message === 'DONATION_NOT_FOUND') {
      return res.status(404).json({
        message: 'Donation not found or you are not its owner.',
      });
    }

    if (error.message === 'ACTIVE_ALLOCATIONS_EXIST') {
      return res.status(409).json({
        message:
          'This donation cannot be cancelled because NGO requests are being processed.',
      });
    }

    if (error.message === 'DONATION_ALREADY_ALLOCATED') {
      return res.status(409).json({
        message:
          'This donation cannot be cancelled because portions have already been allocated.',
      });
    }

    if (error.message === 'DONATION_STATUS_CHANGED') {
      return res.status(409).json({
        message:
          'Donation status changed. Please refresh and try again.',
      });
    }

    return res.status(500).json({
      message: 'Unable to cancel donation.',
    });

  } finally {
    await session.endSession();
  }
};

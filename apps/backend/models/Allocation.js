const mongoose = require('mongoose');

const allocationSchema = new mongoose.Schema(
  {
    donationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Donation',
      required: true,
    },

    donorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    ngoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    ngoName: {
      type: String,
      required: true,
    },

    // Number of portions originally requested by the NGO
    requestedPortions: {
      type: Number,
      required: true,
      min: 1,
    },

    // Number of portions offered by the system
    offeredPortions: {
      type: Number,
      default: null,
      min: 1,
    },

    // Number of portions finally approved by the donor
    allocatedPortions: {
      type: Number,
      default: 0,
      min: 0,
    },

    status: {
      type: String,
      enum: [
        'queued',
        'awaiting_ngo_confirmation',
        'pending_donor',
        'approved',
        'rejected',
        'declined',
        'collected',
        'cancelled',
        'expired',
      ],
      default: 'queued',
    },

    // Only the NGO's allocation API should retrieve this field
    pickupCode: {
      type: String,
      default: null,
      select: false,
    },

    // Pickup details the donor gives when approving. Visible only to the
    // donor and the NGO that owns this allocation.
    pickupAddress: {
      type: String,
      trim: true,
      default: null,
    },

    contactName: {
      type: String,
      trim: true,
      default: null,
    },

    contactPhone: {
      type: String,
      trim: true,
      default: null,
    },

    // Optional exact pickup point (GPS) shared by the donor on approval,
    // used by the NGO for directions.
    pickupLatitude: {
      type: Number,
      min: -90,
      max: 90,
      default: null,
    },

    pickupLongitude: {
      type: Number,
      min: -180,
      max: 180,
      default: null,
    },

    donorDecisionAt: {
      type: Date,
      default: null,
    },

    ngoDecisionAt: {
      type: Date,
      default: null,
    },

    collectedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// Helps retrieve requests in FIFO order for a donation
allocationSchema.index({
  donationId: 1,
  createdAt: 1,
});


module.exports = mongoose.model('Allocation', allocationSchema);

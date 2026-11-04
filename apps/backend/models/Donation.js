
const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema(
  {
    donorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    donorName: {
      type: String,
      required: true,
    },

    title: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      trim: true,
      default: null,
    },

    imageUrl: {
      type: String,
      default: null,
    },

    imagePublicId: {
      type: String,
      default: null,
    },

    // Original quantity posted by the donor
    portions: {
      type: Number,
      required: true,
      min: 1,
    },

    // Quantity still available for allocation
    remainingPortions: {
      type: Number,
      required: true,
      min: 0,
    },

    pickupWindowStart: {
      type: Date,
      required: true,
    },

    pickupWindowEnd: {
      type: Date,
      required: true,
    },

    address: {
      locality: {
        type: String,
        required: true,
        trim: true,
      },
    },

    status: {
      type: String,
      enum: ['available', 'claimed', 'collected', 'cancelled'],
      default: 'available',
    },
    queueRevision: {
  type: Number,
  default: 0,
},
  },
  { timestamps: true }
);

module.exports = mongoose.model('Donation', donationSchema);

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
    portions: {
      type: Number,
      required: true,
      min: 1,
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
  },
  { timestamps: true }
);

module.exports = mongoose.model('Donation', donationSchema);

const mongoose = require('mongoose');

// One in-app alert for one user (donor, NGO or admin).
// Created by the server when something happens that the user should act on.
const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    type: {
      type: String,
      enum: [
        'request_to_review',
        'reduced_offer',
        'request_approved',
        'request_rejected',
        'request_closed',
        'pickup_completed',
        'ngo_verified',
      ],
      required: true,
    },

    title: {
      type: String,
      required: true,
      trim: true,
    },

    body: {
      type: String,
      required: true,
      trim: true,
    },

    donationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Donation',
      default: null,
    },

    allocationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Allocation',
      default: null,
    },

    read: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

notificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);

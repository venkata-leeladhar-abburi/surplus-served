const mongoose = require('mongoose');
const Donation = require('./Donation');

// A donor's standing "I have this surplus regularly" pattern.
// Each day the donor confirms (which posts a real Donation) or skips.
const recurringTemplateSchema = new mongoose.Schema(
  {
    donorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },

    // Usual quantity; the donor can change it when confirming each day.
    portions: {
      type: Number,
      required: true,
      min: 1,
      max: 1000,
    },

    foodCategory: {
      type: String,
      enum: Donation.schema.path('foodCategory').enumValues,
      default: 'other',
    },

    dietType: {
      type: String,
      enum: ['veg', 'non_veg', null],
      default: null,
    },

    // Pickup window length, starting when the donor confirms.
    windowHours: {
      type: Number,
      required: true,
      min: 1,
      max: 12,
    },

    // How long the food stays safe after confirming (>= windowHours).
    safeHours: {
      type: Number,
      required: true,
      min: 1,
      max: 72,
    },

    locality: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },

    active: {
      type: Boolean,
      default: true,
    },

    // Calendar days (YYYY-MM-DD, India time) of the last confirm / skip.
    lastConfirmedOn: {
      type: String,
      default: null,
    },

    lastSkippedOn: {
      type: String,
      default: null,
    },

    lastDonationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Donation',
      default: null,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('RecurringTemplate', recurringTemplateSchema);

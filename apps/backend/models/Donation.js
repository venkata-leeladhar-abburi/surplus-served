
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

    // What kind of food this is (used for display and filtering)
    foodCategory: {
      type: String,
      enum: [
        'cooked_meal',
        'bakery',
        'fruits_vegetables',
        'dairy',
        'groceries',
        'beverages',
        'other',
      ],
      default: 'other',
    },

    dietType: {
      type: String,
      enum: ['veg', 'non_veg'],
      default: null,
    },

    // Time after which the food is no longer safe to eat.
    // Optional in the schema so donations created before this field
    // existed stay valid; the create API requires it.
    expiresAt: {
      type: Date,
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

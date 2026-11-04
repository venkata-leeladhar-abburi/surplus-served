
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    role: {
      type: String,
      enum: ['donor', 'ngo', 'admin'],
      required: true,
    },

    ngoDetails: {
      organizationName: {
        type: String,
        trim: true,
        default: null,
      },

      registrationNumber: {
        type: String,
        trim: true,
        default: null,
      },

      verificationStatus: {
        type: String,
        enum: ['pending', 'verified', 'rejected'],
        default: 'pending',
      },

      documentUrl: {
        type: String,
        default: null,
      },

      rejectionReason: {
        type: String,
        default: null,
      },
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('User', userSchema);

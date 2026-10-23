const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['donor', 'receiver', 'ngo'], required: true },
  ngoDetails: {
    registrationNumber: { type: String },
    verificationStatus: { 
      type: String, 
      enum: ['pending', 'verified', 'rejected'], 
      default: 'pending' 
    },
    documentUrl: { type: String }
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);

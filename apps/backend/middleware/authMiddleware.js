
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const User = require('../models/User');

// Verify JWT and identify the logged-in user
const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        message: 'Not authorized. Please log in.',
      });
    }

    const token = authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        message: 'Authentication token is missing.',
      });
    }

    if (!process.env.JWT_SECRET) {
      return res.status(500).json({
        message: 'Server authentication is not configured.',
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Validate JWT payload
    if (
      !decoded.id ||
      !mongoose.Types.ObjectId.isValid(decoded.id) ||
      !decoded.role
    ) {
      return res.status(401).json({
        message: 'Invalid authentication token.',
      });
    }

    // Fetch the latest user details from MongoDB
    const user = await User.findById(decoded.id).select('-password');

    if (!user || user.role !== decoded.role) {
      return res.status(401).json({
        message: 'Invalid authentication token.',
      });
    }

    // Block NGOs until admin approval
    if (
      user.role === 'ngo' &&
      user.ngoDetails?.verificationStatus !== 'approved'
    ) {
      return res.status(403).json({
        message:
          user.ngoDetails?.verificationStatus === 'rejected'
            ? 'Your NGO registration was rejected. Please contact the administrator.'
            : 'Your NGO account is awaiting admin approval.',
        verificationStatus:
          user.ngoDetails?.verificationStatus || 'pending',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        message: 'Session expired. Please log in again.',
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        message: 'Invalid authentication token.',
      });
    }

    console.error('Authentication error:', error);

    return res.status(500).json({
      message: 'Authentication failed.',
    });
  }
};

// Restrict access based on user role
const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        message: 'You do not have permission to perform this action.',
      });
    }

    next();
  };
};

module.exports = {
  protect,
  authorizeRoles,
};

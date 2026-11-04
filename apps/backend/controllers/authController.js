
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cloudinary = require('../config/cloudinary');

// Generate JWT Token
const generateToken = (id, role) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not configured');
  }

  return jwt.sign(
    { id: id.toString(), role },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

// Register User
const registerUser = async (req, res) => {
  let uploadedDocumentPublicId = null;
  let uploadedDocumentResourceType = 'image';

  try {
    const { password, role } = req.body;

    const name =
      typeof req.body.name === 'string'
        ? req.body.name.trim()
        : '';

    const email =
      typeof req.body.email === 'string'
        ? req.body.email.trim().toLowerCase()
        : '';

    if (!name || !email || !password || !role) {
      return res.status(400).json({
        message: 'Name, email, password and role are required.',
      });
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({
        message: 'Please provide a valid email address.',
      });
    }

    if (typeof password !== 'string' || password.length < 6) {
      return res.status(400).json({
        message: 'Password must be at least 6 characters.',
      });
    }

    if (!['donor', 'ngo'].includes(role)) {
      return res.status(400).json({
        message: 'Invalid role.',
      });
    }

    let ngoDetails = undefined;

    if (role === 'ngo') {
      const organizationName =
        typeof req.body.organizationName === 'string'
          ? req.body.organizationName.trim()
          : typeof req.body.ngoDetails?.organizationName === 'string'
            ? req.body.ngoDetails.organizationName.trim()
            : '';

      const registrationNumber =
        typeof req.body.registrationNumber === 'string'
          ? req.body.registrationNumber.trim()
          : typeof req.body.ngoDetails?.registrationNumber === 'string'
            ? req.body.ngoDetails.registrationNumber.trim()
            : '';

      if (!organizationName || !registrationNumber) {
        return res.status(400).json({
          message: 'NGO organization name and registration number are required.',
        });
      }

      if (!req.file) {
        return res.status(400).json({
          message: 'NGO registration certificate is required.',
        });
      }

      ngoDetails = {
        organizationName,
        registrationNumber,
        verificationStatus: 'pending',
        documentUrl: null,
        rejectionReason: null,
      };
    }

    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(409).json({
        message: 'User already exists.',
      });
    }

    // Upload NGO certificate to Cloudinary
    if (role === 'ngo') {
      uploadedDocumentResourceType =
        req.file.mimetype === 'application/pdf'
          ? 'raw'
          : 'image';

      const uploadResult = await new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder: 'surplus-served/ngo-certificates',
            resource_type: uploadedDocumentResourceType,
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

      ngoDetails.documentUrl = uploadResult.secure_url;
      uploadedDocumentPublicId = uploadResult.public_id;
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role,
      ngoDetails,
    });

    const token = generateToken(user._id, user.role);

    return res.status(201).json({
      message: 'Registration successful.',
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      ngoDetails: user.ngoDetails
        ? {
            organizationName: user.ngoDetails.organizationName,
            registrationNumber: user.ngoDetails.registrationNumber,
            verificationStatus: user.ngoDetails.verificationStatus,
          }
        : undefined,
      token,
    });
  } catch (error) {
    // Remove uploaded certificate if registration fails
    if (uploadedDocumentPublicId) {
      try {
        await cloudinary.uploader.destroy(
          uploadedDocumentPublicId,
          { resource_type: uploadedDocumentResourceType }
        );
      } catch (cleanupError) {
        console.error('Certificate cleanup error:', cleanupError);
      }
    }

    if (error.code === 11000) {
      return res.status(409).json({
        message: 'User already exists.',
      });
    }

    console.error('Registration error:', error);

    return res.status(500).json({
      message: 'Registration failed. Please try again.',
    });
  }
};

// Login User
const loginUser = async (req, res) => {
  try {
    const email =
      typeof req.body.email === 'string'
        ? req.body.email.trim().toLowerCase()
        : '';

    const { password } = req.body;

    if (!email || !password || typeof password !== 'string') {
      return res.status(400).json({
        message: 'Email and password are required.',
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        message: 'No account found. Please register.',
      });
    }

    const isPasswordCorrect = await bcrypt.compare(
      password,
      user.password
    );

    if (!isPasswordCorrect) {
      return res.status(401).json({
        message: 'Invalid email or password.',
      });
    }

    // Check NGO verification before issuing an authentication token
    if (user.role === 'ngo') {
      const verificationStatus =
        user.ngoDetails?.verificationStatus || 'pending';

      if (verificationStatus === 'pending') {
        return res.status(403).json({
          message: 'Your NGO account is awaiting admin approval.',
          verificationStatus: 'pending',
        });
      }

      if (verificationStatus === 'rejected') {
        return res.status(403).json({
          message:
            'Your NGO registration was rejected. Please contact the administrator.',
          verificationStatus: 'rejected',
          rejectionReason: user.ngoDetails?.rejectionReason || null,
        });
      }

      if (verificationStatus !== 'approved') {
        return res.status(403).json({
          message: 'Your NGO account is not approved.',
          verificationStatus,
        });
      }
    }

    const token = generateToken(user._id, user.role);

    return res.status(200).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      ngoDetails: user.ngoDetails
        ? {
            organizationName: user.ngoDetails.organizationName,
            registrationNumber: user.ngoDetails.registrationNumber,
            verificationStatus: user.ngoDetails.verificationStatus,
            rejectionReason: user.ngoDetails.rejectionReason,
          }
        : undefined,
      token,
    });
  } catch (error) {
    console.error('Login error:', error);

    return res.status(500).json({
      message: 'Login failed. Please try again.',
    });
  }
};

// Get currently logged-in user's profile
const getMe = async (req, res) => {
  try {
    return res.status(200).json({
      _id: req.user._id,
      name: req.user.name,
      email: req.user.email,
      role: req.user.role,
      ngoDetails: req.user.ngoDetails
        ? {
            organizationName: req.user.ngoDetails.organizationName,
            registrationNumber: req.user.ngoDetails.registrationNumber,
            verificationStatus: req.user.ngoDetails.verificationStatus,
            rejectionReason: req.user.ngoDetails.rejectionReason,
          }
        : undefined,
      createdAt: req.user.createdAt,
    });
  } catch (error) {
    console.error('Profile error:', error);

    return res.status(500).json({
      message: 'Unable to fetch profile.',
    });
  }
};

// Create the first admin account securely
const createInitialAdmin = async (req, res) => {
  try {
    const { name, email, password, setupSecret } = req.body;

    if (
      !process.env.ADMIN_SETUP_SECRET ||
      !setupSecret ||
      setupSecret !== process.env.ADMIN_SETUP_SECRET
    ) {
      return res.status(403).json({
        message: 'Invalid admin setup credentials.',
      });
    }

    const existingAdmin = await User.findOne({ role: 'admin' });

    if (existingAdmin) {
      return res.status(409).json({
        message: 'An admin account already exists.',
      });
    }

    const cleanName =
      typeof name === 'string' ? name.trim() : '';

    const cleanEmail =
      typeof email === 'string' ? email.trim().toLowerCase() : '';

    if (!cleanName || !cleanEmail || !password) {
      return res.status(400).json({
        message: 'Name, email and password are required.',
      });
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)) {
      return res.status(400).json({
        message: 'Please provide a valid email address.',
      });
    }

    if (typeof password !== 'string' || password.length < 12) {
      return res.status(400).json({
        message: 'Admin password must be at least 12 characters.',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const admin = await User.create({
      name: cleanName,
      email: cleanEmail,
      password: hashedPassword,
      role: 'admin',
    });

    return res.status(201).json({
      message: 'Initial admin account created successfully.',
      admin: {
        _id: admin._id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
      },
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        message: 'An account with this email already exists.',
      });
    }

    console.error('Admin creation error:', error);

    return res.status(500).json({
      message: 'Unable to create admin account.',
    });
  }
};

module.exports = {
  registerUser,
  loginUser,
  getMe,
  createInitialAdmin,
};

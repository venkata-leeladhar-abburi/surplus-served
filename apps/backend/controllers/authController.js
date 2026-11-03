
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

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
  try {
    const { password, role, ngoDetails } = req.body;

    const name = typeof req.body.name === 'string'
      ? req.body.name.trim()
      : '';

    const email = typeof req.body.email === 'string'
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

    if (!['donor', 'receiver', 'ngo'].includes(role)) {
      return res.status(400).json({
        message: 'Invalid role.',
      });
    }

    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(409).json({
        message: 'User already exists.',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role,
      ngoDetails: role === 'ngo' ? ngoDetails : undefined,
    });

    const token = generateToken(user._id, user.role);

    return res.status(201).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      token,
    });
  } catch (error) {
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
    const email = typeof req.body.email === 'string'
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

    const token = generateToken(user._id, user.role);

    return res.status(200).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
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
      ngoDetails: req.user.ngoDetails,
      createdAt: req.user.createdAt,
    });
  } catch (error) {
    console.error('Profile error:', error);

    return res.status(500).json({
      message: 'Unable to fetch profile.',
    });
  }
};

module.exports = {
  registerUser,
  loginUser,
  getMe,
};

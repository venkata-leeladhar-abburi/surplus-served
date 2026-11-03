
const express = require('express');
const router = express.Router();

const {
  registerUser,
  loginUser,
  getMe,
   createInitialAdmin,
} = require('../controllers/authController');

const { protect } = require('../middleware/authMiddleware');

// Public routes
router.post('/register', registerUser);
router.post('/login', loginUser);
// One-time initial admin setup
router.post('/setup-admin', createInitialAdmin);

// Protected routes
router.get('/me', protect, getMe);

module.exports = router;

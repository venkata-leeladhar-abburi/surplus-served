const express = require('express');
const router = express.Router();

const {
  registerUser,
  loginUser,
  getMe,
} = require('../controllers/authController');

const { protect } = require('../middleware/authMiddleware');
const certificateUpload = require('../middleware/certificateUploadMiddleware');

// Public routes
router.post(
  '/register',
  certificateUpload.single('certificate'),
  registerUser
);

router.post('/login', loginUser);

// Protected routes
router.get('/me', protect, getMe);

module.exports = router;

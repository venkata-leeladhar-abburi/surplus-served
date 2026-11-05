const express = require('express');
const router = express.Router();

const {
  registerUser,
  loginUser,
  getMe,
  createInitialAdmin,
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

// One-time admin bootstrap. Works only when ADMIN_SETUP_SECRET is set
// on the server, the request sends the same setupSecret, and no admin
// exists yet. Returns 409 once an admin account exists.
router.post('/setup-admin', createInitialAdmin);

// Protected routes
router.get('/me', protect, getMe);

module.exports = router;

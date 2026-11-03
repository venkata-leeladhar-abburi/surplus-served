
const express = require('express');
const router = express.Router();

const {
  getPendingNGOs,
  approveNGO,
  rejectNGO,
} = require('../controllers/adminController');

const {
  protect,
  authorizeRoles,
} = require('../middleware/authMiddleware');

// All routes require admin authentication
router.use(protect, authorizeRoles('admin'));

// View pending NGO applications
router.get('/ngos/pending', getPendingNGOs);

// Approve an NGO
router.patch('/ngos/:id/approve', approveNGO);

// Reject an NGO
router.patch('/ngos/:id/reject', rejectNGO);

module.exports = router;

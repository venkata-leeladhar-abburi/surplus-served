
const express = require('express');
const router = express.Router();

const {
  getPendingNGOs,
  getNGOs,
  approveNGO,
  rejectNGO,
  getStats,
  getUsers,
  getDonations,
  getActivity,
} = require('../controllers/adminController');

const {
  protect,
  authorizeRoles,
} = require('../middleware/authMiddleware');

// All routes require admin authentication
router.use(protect, authorizeRoles('admin'));

// Dashboard overview counts
router.get('/stats', getStats);

// View pending NGO applications
router.get('/ngos/pending', getPendingNGOs);

// View all NGOs, optionally ?status=pending|verified|rejected
router.get('/ngos', getNGOs);

// Approve an NGO
router.patch('/ngos/:id/approve', approveNGO);

// Reject an NGO
router.patch('/ngos/:id/reject', rejectNGO);

// Read-only platform lists
router.get('/users', getUsers);
router.get('/donations', getDonations);
router.get('/activity', getActivity);

module.exports = router;

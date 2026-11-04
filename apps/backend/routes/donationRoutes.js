
const express = require('express');
const router = express.Router();

const donationController = require('../controllers/donationController');
const allocationController = require('../controllers/allocationController');
const dashboardController = require('../controllers/dashboardController');
const upload = require('../middleware/uploadMiddleware');

const {
  protect,
  authorizeRoles,
} = require('../middleware/authMiddleware');

// --------------------------------------------------
// Donor routes
// --------------------------------------------------

// Create donation
router.post(
  '/',
  protect,
  authorizeRoles('donor'),
  upload.single('image'),
  donationController.createDonation
);

// Get donor's donations
router.get(
  '/mine',
  protect,
  authorizeRoles('donor'),
  donationController.getMyDonations
);

// Get donor's allocations
router.get(
  '/my-donor-allocations',
  protect,
  authorizeRoles('donor'),
  allocationController.getMyDonorAllocations
);

// Donor dashboard
router.get(
  '/dashboard/donor',
  protect,
  authorizeRoles('donor'),
  dashboardController.getDonorDashboard
);

// Cancel donation
router.patch(
  '/:id/cancel',
  protect,
  authorizeRoles('donor'),
  donationController.cancelDonation
);

// Donor approves NGO allocation
router.post(
  '/allocations/:allocationId/approve',
  protect,
  authorizeRoles('donor'),
  allocationController.approveAllocation
);

// Donor rejects NGO allocation
router.post(
  '/allocations/:allocationId/reject',
  protect,
  authorizeRoles('donor'),
  allocationController.rejectAllocation
);

// Donor verifies pickup code
router.post(
  '/allocations/:allocationId/verify-pickup',
  protect,
  authorizeRoles('donor'),
  allocationController.verifyPickupCode
);

// --------------------------------------------------
// NGO routes
// --------------------------------------------------

// NGO dashboard
router.get(
  '/dashboard/ngo',
  protect,
  authorizeRoles('ngo'),
  dashboardController.getNgoDashboard
);

// NGO views its own allocations and pickup codes
router.get(
  '/my-allocations',
  protect,
  authorizeRoles('ngo'),
  allocationController.getMyAllocations
);

// NGO requests donation
router.post(
  '/:id/request',
  protect,
  authorizeRoles('ngo'),
  allocationController.requestDonation
);

// NGO accepts or rejects reduced quantity offer
router.post(
  '/allocations/:allocationId/confirm-offer',
  protect,
  authorizeRoles('ngo'),
  allocationController.confirmOffer
);

// Only NGOs can browse donations
router.get(
  '/',
  protect,
  authorizeRoles('ngo'),
  donationController.getDonations
);

// --------------------------------------------------
// Individual donation details
// Keep this dynamic route after specific GET routes.
// --------------------------------------------------

router.get(
  '/:id',
  protect,
  authorizeRoles('donor', 'ngo'),
  donationController.getDonationById
);

module.exports = router;

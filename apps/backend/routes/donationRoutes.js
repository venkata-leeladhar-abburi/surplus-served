
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

// Donor routes
router.post(
  '/',
  protect,
  authorizeRoles('donor'),
  upload.single('image'),
  donationController.createDonation
);

router.get(
  '/mine',
  protect,
  authorizeRoles('donor'),
  donationController.getMyDonations
);

router.patch(
  '/:id/cancel',
  protect,
  authorizeRoles('donor'),
  donationController.cancelDonation
);

// Receiver routes
router.get(
  '/',
  protect,
  authorizeRoles('receiver', 'ngo'),
  donationController.getDonations
);

// Receiver allocation routes
router.get(
  '/my-allocations',
  protect,
  authorizeRoles('receiver', 'ngo'),
  allocationController.getMyAllocations
);

router.post(
  '/:id/request',
  protect,
  authorizeRoles('receiver', 'ngo'),
  allocationController.requestDonation
);

router.post(
  '/:id/verify-pickup',
  protect,
  authorizeRoles('receiver', 'ngo'),
  allocationController.verifyPickupCode
);

router.get(
  '/dashboard/donor',
  protect,
  authorizeRoles('donor'),
  dashboardController.getDonorDashboard
);

router.get(
  '/dashboard/receiver',
  protect,
  authorizeRoles('receiver', 'ngo'),
  dashboardController.getReceiverDashboard
);

// Individual donation details
router.get(
  '/:id',
  protect,
  authorizeRoles('donor', 'receiver', 'ngo'),
  donationController.getDonationById
);







module.exports = router;

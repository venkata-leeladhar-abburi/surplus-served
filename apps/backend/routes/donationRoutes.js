
const express = require('express');
const router = express.Router();

const donationController = require('../controllers/donationController');

const {
  protect,
  authorizeRoles,
} = require('../middleware/authMiddleware');

// Donor routes
router.post(
  '/',
  protect,
  authorizeRoles('donor'),
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

// Individual donation details
router.get(
  '/:id',
  protect,
  authorizeRoles('donor', 'receiver', 'ngo'),
  donationController.getDonationById
);

module.exports = router;

const express = require('express');
const router = express.Router();

const notificationController = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

// Every logged-in role has its own alerts.
router.get('/', protect, notificationController.getMyNotifications);
router.post('/read-all', protect, notificationController.markAllRead);
router.patch('/:id/read', protect, notificationController.markRead);

module.exports = router;

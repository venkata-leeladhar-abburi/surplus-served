const express = require('express');
const router = express.Router();

const recurringController = require('../controllers/recurringController');
const { protect, authorizeRoles } = require('../middleware/authMiddleware');

// Donor-only: standing templates for food donated regularly.
router.use(protect, authorizeRoles('donor'));

router.get('/', recurringController.getMyTemplates);
router.post('/', recurringController.createTemplate);
router.patch('/:id', recurringController.updateTemplate);
router.delete('/:id', recurringController.deleteTemplate);
router.post('/:id/confirm', recurringController.confirmToday);
router.post('/:id/skip', recurringController.skipToday);

module.exports = router;

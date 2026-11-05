
const crypto = require('crypto');
const mongoose = require('mongoose');

const Donation = require('../models/Donation');
const Allocation = require('../models/Allocation');

const ACTIVE_STATUSES = [
  'awaiting_ngo_confirmation',
  'pending_donor',
];

const UNRESOLVED_NGO_STATUSES = [
  'queued',
  'awaiting_ngo_confirmation',
  'pending_donor',
  'approved',
];

// Serialize queue operations by writing to the same Donation document.
const acquireQueueLock = async (donationId, session) => {
  const result = await Donation.updateOne(
    { _id: donationId },
    { $inc: { queueRevision: 1 } },
    { session }
  );

  if (result.matchedCount !== 1) {
    throw new Error('DONATION_NOT_FOUND');
  }
};

// Activate the oldest queued request for a donation.
const activateNextRequest = async (donationId) => {
  const session = await mongoose.startSession();

  try {
    await session.withTransaction(async () => {
      const donation = await Donation.findById(donationId).session(session);

      if (!donation) return;

      await acquireQueueLock(donationId, session);

      const currentDonation = await Donation.findById(donationId).session(
        session
      );

      if (!currentDonation) return;

      // Expire requests if the donation can no longer be fulfilled.
      if (
        !currentDonation.pickupWindowEnd ||
        currentDonation.pickupWindowEnd <= new Date() ||
        currentDonation.remainingPortions <= 0 ||
        currentDonation.status !== 'available'
      ) {
        await Allocation.updateMany(
          {
            donationId,
            status: {
              $in: [
                'queued',
                'awaiting_ngo_confirmation',
                'pending_donor',
              ],
            },
          },
          {
            $set: { status: 'expired' },
          },
          { session }
        );

        return;
      }

      // Do not activate another request while one is unresolved.
      const activeRequest = await Allocation.findOne({
        donationId,
        status: { $in: ACTIVE_STATUSES },
      }).session(session);

      if (activeRequest) return;

      // FIFO: oldest queued request first.
      const nextRequest = await Allocation.findOne({
        donationId,
        status: 'queued',
      })
        .sort({ createdAt: 1, _id: 1 })
        .session(session);

      if (!nextRequest) return;

      const available = currentDonation.remainingPortions;

      const offeredPortions = Math.min(
        nextRequest.requestedPortions,
        available
      );

      const nextStatus =
        nextRequest.requestedPortions > available
          ? 'awaiting_ngo_confirmation'
          : 'pending_donor';

      await Allocation.updateOne(
        {
          _id: nextRequest._id,
          status: 'queued',
        },
        {
          $set: {
            offeredPortions,
            status: nextStatus,
          },
        },
        { session }
      );
    });
  } finally {
    await session.endSession();
  }
};

// Refresh the queue after a transaction fails because a donation
// may have expired or become unavailable.
const safelyActivateNextRequest = async (donationId) => {
  if (!donationId) return;

  try {
    await activateNextRequest(donationId);
  } catch (error) {
    console.error('Queue refresh error:', error);
  }
};

// POST /api/donations/:id/request
// Only verified NGOs can request donations.
exports.requestDonation = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { id } = req.params;
    const requestedPortions = Number(req.body.portions);

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    if (!Number.isInteger(requestedPortions) || requestedPortions < 1) {
      return res.status(400).json({
        message: 'Please enter a valid number of portions.',
      });
    }

    const ngo = req.user;

    if (
      ngo.role !== 'ngo' ||
      ngo.ngoDetails?.verificationStatus !== 'verified'
    ) {
      return res.status(403).json({
        message: 'Only verified NGOs can request donations.',
        verificationStatus:
          ngo.ngoDetails?.verificationStatus || 'not_applicable',
      });
    }

    let allocation;

    await session.withTransaction(async () => {
      const donation = await Donation.findOne({
        _id: id,
        donorId: { $ne: ngo._id },
        status: 'available',
        remainingPortions: { $gt: 0 },
        pickupWindowEnd: { $gt: new Date() },
      }).session(session);

      if (!donation) {
        throw new Error('DONATION_NOT_AVAILABLE');
      }

      await acquireQueueLock(donation._id, session);

      const existingRequest = await Allocation.findOne({
        donationId: donation._id,
        ngoId: ngo._id,
        status: { $in: UNRESOLVED_NGO_STATUSES },
      }).session(session);

      if (existingRequest) {
        throw new Error('DUPLICATE_NGO_REQUEST');
      }

      const created = await Allocation.create(
        [
          {
            donationId: donation._id,
            donorId: donation.donorId,
            ngoId: ngo._id,
            ngoName: ngo.ngoDetails?.organizationName || ngo.name,
            requestedPortions,
            status: 'queued',
          },
        ],
        { session }
      );

      allocation = created[0];
    });

    await activateNextRequest(id);

    const updatedAllocation = await Allocation.findById(allocation._id);

    return res.status(201).json({
      message: 'Donation request submitted successfully.',
      allocation: updatedAllocation,
    });
  } catch (error) {
    console.error('Donation request error:', error);

    if (error.message === 'DONATION_NOT_AVAILABLE') {
      return res.status(404).json({
        message: 'Donation not found or no longer available.',
      });
    }

    if (error.message === 'DUPLICATE_NGO_REQUEST') {
      return res.status(409).json({
        message: 'You already have an active request for this donation.',
      });
    }

    return res.status(500).json({
      message: 'Unable to submit donation request.',
    });
  } finally {
    await session.endSession();
  }
};

// POST /api/donations/allocations/:allocationId/confirm-offer
// NGO accepts or rejects a reduced quantity.
exports.confirmOffer = async (req, res) => {
  const session = await mongoose.startSession();

  let donationId = null;

  try {
    const { allocationId } = req.params;
    const { accept } = req.body;

    if (!mongoose.Types.ObjectId.isValid(allocationId)) {
      return res.status(400).json({
        message: 'Invalid allocation ID.',
      });
    }

    if (typeof accept !== 'boolean') {
      return res.status(400).json({
        message: 'Please specify accept as true or false.',
      });
    }

    if (
      req.user.role !== 'ngo' ||
      req.user.ngoDetails?.verificationStatus !== 'verified'
    ) {
      return res.status(403).json({
        message: 'Only verified NGOs can confirm offers.',
      });
    }

    let updatedAllocation = null;

    await session.withTransaction(async () => {
      const allocation = await Allocation.findOne({
        _id: allocationId,
        ngoId: req.user._id,
        status: 'awaiting_ngo_confirmation',
      }).session(session);

      if (!allocation) {
        throw new Error('OFFER_NOT_FOUND');
      }

      donationId = allocation.donationId;

      await acquireQueueLock(donationId, session);

      const donation = await Donation.findById(donationId).session(session);

      if (
        !donation ||
        !donation.pickupWindowEnd ||
        donation.pickupWindowEnd <= new Date() ||
        donation.remainingPortions <= 0 ||
        donation.status !== 'available'
      ) {
        throw new Error('DONATION_UNAVAILABLE');
      }

      updatedAllocation = await Allocation.findOneAndUpdate(
        {
          _id: allocationId,
          ngoId: req.user._id,
          status: 'awaiting_ngo_confirmation',
        },
        {
          $set: {
            status: accept ? 'pending_donor' : 'declined',
            ngoDecisionAt: new Date(),
          },
        },
        {
          new: true,
          session,
        }
      );

      if (!updatedAllocation) {
        throw new Error('OFFER_ALREADY_PROCESSED');
      }
    });

    if (!accept) {
      await activateNextRequest(donationId);
    }

    return res.status(200).json({
      message: accept
        ? 'Offer accepted. Waiting for donor approval.'
        : 'Offer declined. The next NGO will be considered.',
      allocation: updatedAllocation,
    });
  } catch (error) {
    console.error('NGO offer confirmation error:', error);

    if (
      error.message === 'DONATION_UNAVAILABLE' &&
      donationId
    ) {
      await safelyActivateNextRequest(donationId);

      return res.status(409).json({
        message:
          'This donation is no longer available or its pickup window has ended.',
      });
    }

    if (
      error.message === 'OFFER_NOT_FOUND' ||
      error.message === 'OFFER_ALREADY_PROCESSED'
    ) {
      return res.status(409).json({
        message: 'This offer is no longer awaiting your confirmation.',
      });
    }

    return res.status(500).json({
      message: 'Unable to process your confirmation.',
    });
  } finally {
    await session.endSession();
  }
};

// POST /api/donations/allocations/:allocationId/approve
// Donor approves an NGO request.
// Portions are deducted only after approval.
exports.approveAllocation = async (req, res) => {
  const session = await mongoose.startSession();

  let donationId = null;

  try {
    const { allocationId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(allocationId)) {
      return res.status(400).json({
        message: 'Invalid allocation ID.',
      });
    }

    let approvedAllocation = null;

    await session.withTransaction(async () => {
      const allocation = await Allocation.findOne({
        _id: allocationId,
        donorId: req.user._id,
        status: 'pending_donor',
      }).session(session);

      if (!allocation) {
        throw new Error('ALLOCATION_NOT_PENDING');
      }

      donationId = allocation.donationId;

      const quantity = allocation.offeredPortions;

      if (!Number.isInteger(quantity) || quantity < 1) {
        throw new Error('INVALID_OFFERED_QUANTITY');
      }

      const currentDonation = await Donation.findById(donationId).session(
        session
      );

      if (
        !currentDonation ||
        !currentDonation.pickupWindowEnd ||
        currentDonation.pickupWindowEnd <= new Date() ||
        currentDonation.status !== 'available' ||
        currentDonation.remainingPortions < quantity
      ) {
        throw new Error('INSUFFICIENT_PORTIONS');
      }

      const donation = await Donation.findOneAndUpdate(
        {
          _id: donationId,
          donorId: req.user._id,
          status: 'available',
          remainingPortions: { $gte: quantity },
          pickupWindowEnd: { $gt: new Date() },
        },
        {
          $inc: {
            remainingPortions: -quantity,
          },
        },
        {
          new: true,
          session,
        }
      );

      if (!donation) {
        throw new Error('INSUFFICIENT_PORTIONS');
      }

      if (donation.remainingPortions === 0) {
        await Donation.updateOne(
          { _id: donation._id },
          { $set: { status: 'claimed' } },
          { session }
        );
      }

      const pickupCode = String(crypto.randomInt(100000, 1000000));

      const updated = await Allocation.findOneAndUpdate(
        {
          _id: allocationId,
          donorId: req.user._id,
          status: 'pending_donor',
        },
        {
          $set: {
            status: 'approved',
            allocatedPortions: quantity,
            pickupCode,
            donorDecisionAt: new Date(),
          },
        },
        {
          new: true,
          session,
        }
      );

      if (!updated) {
        throw new Error('ALLOCATION_UPDATE_FAILED');
      }

      approvedAllocation = updated;
    });

    await activateNextRequest(donationId);

    return res.status(200).json({
      message: 'Allocation approved successfully.',
      allocation: {
        _id: approvedAllocation._id,
        ngoName: approvedAllocation.ngoName,
        allocatedPortions: approvedAllocation.allocatedPortions,
        status: approvedAllocation.status,
      },
    });
  } catch (error) {
    console.error('Allocation approval error:', error);

    if (
      error.message === 'INSUFFICIENT_PORTIONS' &&
      donationId
    ) {
      await safelyActivateNextRequest(donationId);

      return res.status(409).json({
        message:
          'Not enough portions are available or the pickup window has ended. The request could not be approved.',
      });
    }

    if (error.message === 'ALLOCATION_NOT_PENDING') {
      return res.status(404).json({
        message: 'No pending allocation found for your donation.',
      });
    }

    if (error.message === 'INVALID_OFFERED_QUANTITY') {
      return res.status(400).json({
        message: 'Invalid offered quantity.',
      });
    }

    return res.status(500).json({
      message: 'Unable to approve allocation.',
    });
  } finally {
    await session.endSession();
  }
};

// POST /api/donations/allocations/:allocationId/reject
// Donor rejects an NGO request.
exports.rejectAllocation = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { allocationId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(allocationId)) {
      return res.status(400).json({
        message: 'Invalid allocation ID.',
      });
    }

    let rejectedAllocation = null;
    let donationId = null;

    await session.withTransaction(async () => {
      const allocation = await Allocation.findOne({
        _id: allocationId,
        donorId: req.user._id,
        status: 'pending_donor',
      }).session(session);

      if (!allocation) {
        throw new Error('ALLOCATION_NOT_PENDING');
      }

      donationId = allocation.donationId;

      await acquireQueueLock(donationId, session);

      rejectedAllocation = await Allocation.findOneAndUpdate(
        {
          _id: allocationId,
          donorId: req.user._id,
          status: 'pending_donor',
        },
        {
          $set: {
            status: 'rejected',
            donorDecisionAt: new Date(),
          },
        },
        {
          new: true,
          session,
        }
      );

      if (!rejectedAllocation) {
        throw new Error('ALLOCATION_ALREADY_PROCESSED');
      }
    });

    await activateNextRequest(donationId);

    return res.status(200).json({
      message: 'Request rejected. The next NGO will be considered.',
      allocation: rejectedAllocation,
    });
  } catch (error) {
    console.error('Allocation rejection error:', error);

    if (
      error.message === 'ALLOCATION_NOT_PENDING' ||
      error.message === 'ALLOCATION_ALREADY_PROCESSED'
    ) {
      return res.status(409).json({
        message: 'No pending allocation found or it was already processed.',
      });
    }

    return res.status(500).json({
      message: 'Unable to reject allocation.',
    });
  } finally {
    await session.endSession();
  }
};

// GET /api/donations/my-allocations
// Only the owning verified NGO can retrieve its pickup codes.
exports.getMyAllocations = async (req, res) => {
  try {
    if (
      req.user.role !== 'ngo' ||
      req.user.ngoDetails?.verificationStatus !== 'verified'
    ) {
      return res.status(403).json({
        message: 'Only verified NGOs can access their allocations.',
      });
    }

    const { status } = req.query;

    const allowedStatuses = [
      'queued',
      'awaiting_ngo_confirmation',
      'pending_donor',
      'approved',
      'rejected',
      'declined',
      'collected',
      'cancelled',
      'expired',
    ];

    if (status && !allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: 'Invalid allocation status filter.',
        allowedStatuses,
      });
    }

    const filter = {
      ngoId: req.user._id,
    };

    if (status) {
      filter.status = status;
    }

    const allocations = await Allocation.find(filter)
      .select('+pickupCode')
      .populate(
        'donationId',
        'title description imageUrl address pickupWindowStart pickupWindowEnd donorName portions remainingPortions status expiresAt foodCategory dietType'
      )
      .sort({ createdAt: -1 });

    return res.status(200).json({
      count: allocations.length,
      allocations,
    });
  } catch (error) {
    console.error('Fetch NGO allocations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch your allocations.',
    });
  }
};

// GET /api/donations/my-donor-allocations
// Donor retrieves their own allocations without exposing pickup codes.
exports.getMyDonorAllocations = async (req, res) => {
  try {
    if (req.user.role !== 'donor') {
      return res.status(403).json({
        message: 'Only donors can access their allocations.',
      });
    }

    const { status } = req.query;

    const allowedStatuses = [
      'queued',
      'awaiting_ngo_confirmation',
      'pending_donor',
      'approved',
      'rejected',
      'declined',
      'collected',
      'cancelled',
      'expired',
    ];

    if (status && !allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: 'Invalid allocation status filter.',
        allowedStatuses,
      });
    }

    const filter = {
      donorId: req.user._id,
    };

    if (status) {
      filter.status = status;
    }

    const allocations = await Allocation.find(filter)
      .populate(
        'donationId',
        'title description imageUrl address pickupWindowStart pickupWindowEnd donorName portions remainingPortions status expiresAt foodCategory dietType'
      )
      .sort({ createdAt: -1 });

    return res.status(200).json({
      count: allocations.length,
      allocations,
    });
  } catch (error) {
    console.error('Fetch donor allocations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch your allocations.',
    });
  }
};

// POST /api/donations/allocations/:allocationId/verify-pickup
// Only the original donor verifies the NGO's pickup code.
exports.verifyPickupCode = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { allocationId } = req.params;
    const code = String(req.body.code || '').trim();

    if (!mongoose.Types.ObjectId.isValid(allocationId)) {
      return res.status(400).json({
        message: 'Invalid allocation ID.',
      });
    }

    if (!/^\d{6}$/.test(code)) {
      return res.status(400).json({
        message: 'Enter a valid 6-digit pickup code.',
      });
    }

    let updatedAllocation = null;

    await session.withTransaction(async () => {
      const allocation = await Allocation.findOne({
        _id: allocationId,
        donorId: req.user._id,
        status: 'approved',
      })
        .select('+pickupCode')
        .session(session);

      if (!allocation) {
        throw new Error('ALLOCATION_NOT_ACTIVE');
      }

      if (allocation.pickupCode !== code) {
        throw new Error('INCORRECT_PICKUP_CODE');
      }

      const updated = await Allocation.findOneAndUpdate(
        {
          _id: allocationId,
          donorId: req.user._id,
          status: 'approved',
          pickupCode: code,
        },
        {
          $set: {
            status: 'collected',
            collectedAt: new Date(),
            pickupCode: null,
          },
        },
        {
          new: true,
          session,
        }
      );

      if (!updated) {
        throw new Error('ALLOCATION_ALREADY_PROCESSED');
      }

      await acquireQueueLock(allocation.donationId, session);

      const donation = await Donation.findById(
        allocation.donationId
      ).session(session);

      if (!donation) {
        throw new Error('DONATION_NOT_FOUND');
      }

      // Portions were already deducted during approval.
      // Pickup verification must not deduct them again.
      if (donation.remainingPortions === 0) {
        const otherApproved = await Allocation.exists({
          donationId: donation._id,
          status: 'approved',
        }).session(session);

        if (!otherApproved) {
          await Donation.updateOne(
            {
              _id: donation._id,
              remainingPortions: 0,
            },
            {
              $set: { status: 'collected' },
            },
            { session }
          );
        }
      }

      updatedAllocation = updated;
    });

    return res.status(200).json({
      message: 'Food collection confirmed successfully.',
      allocation: {
        _id: updatedAllocation._id,
        ngoName: updatedAllocation.ngoName,
        allocatedPortions: updatedAllocation.allocatedPortions,
        status: updatedAllocation.status,
        collectedAt: updatedAllocation.collectedAt,
      },
    });
  } catch (error) {
    console.error('Pickup verification error:', error);

    if (error.message === 'ALLOCATION_NOT_ACTIVE') {
      return res.status(404).json({
        message: 'No active allocation found.',
      });
    }

    if (error.message === 'INCORRECT_PICKUP_CODE') {
      return res.status(400).json({
        message: 'Incorrect pickup code.',
      });
    }

    if (error.message === 'ALLOCATION_ALREADY_PROCESSED') {
      return res.status(409).json({
        message: 'Allocation has already been collected or changed.',
      });
    }

    if (error.message === 'DONATION_NOT_FOUND') {
      return res.status(404).json({
        message: 'The associated donation could not be found.',
      });
    }

    return res.status(500).json({
      message: 'Unable to verify pickup code.',
    });
  } finally {
    await session.endSession();
  }
};



// GET /api/donations/my-donor-allocations
// Fetch allocations belonging to the logged-in donor.
// Pickup codes are intentionally hidden from this response.
exports.getMyDonorAllocations = async (req, res) => {
  try {
    if (req.user.role !== 'donor') {
      return res.status(403).json({
        message: 'Only donors can access their allocations.',
      });
    }

    const { status } = req.query;

    const allowedStatuses = [
      'queued',
      'awaiting_ngo_confirmation',
      'pending_donor',
      'approved',
      'rejected',
      'declined',
      'collected',
      'cancelled',
      'expired',
    ];

    if (status && !allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: 'Invalid allocation status filter.',
        allowedStatuses,
      });
    }

    const filter = {
      donorId: req.user._id,
    };

    if (status) {
      filter.status = status;
    }

    const allocations = await Allocation.find(filter)
      .populate(
        'donationId',
        'title description imageUrl address pickupWindowStart pickupWindowEnd donorName portions remainingPortions status expiresAt foodCategory dietType'
      )
      .sort({ createdAt: -1 });

    return res.status(200).json({
      count: allocations.length,
      allocations,
    });
  } catch (error) {
    console.error('Fetch donor allocations error:', error);

    return res.status(500).json({
      message: 'Unable to fetch your allocations.',
    });
  }
};

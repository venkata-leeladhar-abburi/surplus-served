
const crypto = require('crypto');
const mongoose = require('mongoose');
const Donation = require('../models/Donation');
const Allocation = require('../models/Allocation');

const ACTIVE_STATUSES = [
  'awaiting_ngo_confirmation',
  'pending_donor',
];

// Activate the oldest queued request for a donation.
const activateNextRequest = async (donationId) => {
  const session = await mongoose.startSession();

  try {
    await session.withTransaction(async () => {
      const donation = await Donation.findById(donationId).session(session);

      if (!donation) return;

      // Expire queued requests if the pickup window has ended
      if (
        donation.pickupWindowEnd <= new Date() ||
        donation.remainingPortions <= 0
      ) {
        await Allocation.updateMany(
          { donationId, status: 'queued' },
          { $set: { status: 'expired' } },
          { session }
        );
        return;
      }

      // Do not activate another request while one is unresolved
      const activeRequest = await Allocation.findOne({
        donationId,
        status: { $in: ACTIVE_STATUSES },
      }).session(session);

      if (activeRequest) return;

      const nextRequest = await Allocation.findOne({
        donationId,
        status: 'queued',
      })
        .sort({ createdAt: 1, _id: 1 })
        .session(session);

      if (!nextRequest) return;

      const available = donation.remainingPortions;

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

// POST /api/donations/:id/request
// Only verified NGOs can request donations.
exports.requestDonation = async (req, res) => {
  try {
    const { id } = req.params;
    const requestedPortions = Number(req.body.portions);

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Invalid donation ID.',
      });
    }

    if (
      !Number.isInteger(requestedPortions) ||
      requestedPortions < 1
    ) {
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

    const donation = await Donation.findOne({
      _id: id,
      donorId: { $ne: ngo._id },
      status: 'available',
      remainingPortions: { $gt: 0 },
      pickupWindowEnd: { $gt: new Date() },
    });

    if (!donation) {
      return res.status(404).json({
        message: 'Donation not found or no longer available.',
      });
    }

    // Prevent duplicate unresolved requests by the same NGO
    const existingRequest = await Allocation.findOne({
      donationId: id,
      ngoId: ngo._id,
      status: {
        $in: [
          'queued',
          'awaiting_ngo_confirmation',
          'pending_donor',
          'approved',
        ],
      },
    });

    if (existingRequest) {
      return res.status(409).json({
        message: 'You already have an active request for this donation.',
        allocationId: existingRequest._id,
        status: existingRequest.status,
      });
    }

    const [allocation] = await Allocation.create([
      {
        donationId: donation._id,
        donorId: donation.donorId,
        ngoId: ngo._id,
        ngoName: ngo.ngoDetails?.organizationName || ngo.name,
        requestedPortions,
        status: 'queued',
      },
    ]);

    await activateNextRequest(donation._id);

    const updatedAllocation = await Allocation.findById(
      allocation._id
    );

    return res.status(201).json({
      message: 'Donation request submitted successfully.',
      allocation: updatedAllocation,
    });
  } catch (error) {
    console.error('Donation request error:', error);

    return res.status(500).json({
      message: 'Unable to submit donation request.',
    });
  }
};

// POST /api/donations/allocations/:allocationId/confirm-offer
// NGO accepts or rejects a reduced quantity.
exports.confirmOffer = async (req, res) => {
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

    const allocation = await Allocation.findOne({
      _id: allocationId,
      ngoId: req.user._id,
      status: 'awaiting_ngo_confirmation',
    });

    if (!allocation) {
      return res.status(404).json({
        message: 'No offer awaiting your confirmation was found.',
      });
    }

    if (accept) {
      const updated = await Allocation.findOneAndUpdate(
        {
          _id: allocationId,
          ngoId: req.user._id,
          status: 'awaiting_ngo_confirmation',
        },
        {
          $set: {
            status: 'pending_donor',
            ngoDecisionAt: new Date(),
          },
        },
        { new: true }
      );

      return res.status(200).json({
        message: 'Offer accepted. Waiting for donor approval.',
        allocation: updated,
      });
    }

    const updated = await Allocation.findOneAndUpdate(
      {
        _id: allocationId,
        ngoId: req.user._id,
        status: 'awaiting_ngo_confirmation',
      },
      {
        $set: {
          status: 'declined',
          ngoDecisionAt: new Date(),
        },
      },
      { new: true }
    );

    await activateNextRequest(allocation.donationId);

    return res.status(200).json({
      message: 'Offer declined. The next NGO will be considered.',
      allocation: updated,
    });
  } catch (error) {
    console.error('NGO offer confirmation error:', error);

    return res.status(500).json({
      message: 'Unable to process your confirmation.',
    });
  }
};

// POST /api/donations/allocations/:allocationId/approve
// Donor approves an NGO request.
// Portions are deducted only after approval.
exports.approveAllocation = async (req, res) => {
  const session = await mongoose.startSession();

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

      const quantity = allocation.offeredPortions;

      // Atomic quantity deduction
      const donation = await Donation.findOneAndUpdate(
        {
          _id: allocation.donationId,
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

      // If all portions are allocated, mark donation as claimed
      if (donation.remainingPortions === 0) {
        await Donation.updateOne(
          { _id: donation._id },
          { $set: { status: 'claimed' } },
          { session }
        );
      }

      // Generate a unique six-digit pickup code for this allocation
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

    // Activate the next NGO only after approval is committed
    await activateNextRequest(approvedAllocation.donationId);

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

    if (error.message === 'ALLOCATION_NOT_PENDING') {
      return res.status(404).json({
        message: 'No pending allocation found for your donation.',
      });
    }

    if (error.message === 'INSUFFICIENT_PORTIONS') {
      return res.status(409).json({
        message: 'Not enough portions are available or the pickup window has ended.',
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
  try {
    const { allocationId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(allocationId)) {
      return res.status(400).json({
        message: 'Invalid allocation ID.',
      });
    }

    const allocation = await Allocation.findOneAndUpdate(
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
      { new: true }
    );

    if (!allocation) {
      return res.status(404).json({
        message: 'No pending allocation found.',
      });
    }

    await activateNextRequest(allocation.donationId);

    return res.status(200).json({
      message: 'Request rejected. The next NGO will be considered.',
      allocation,
    });
  } catch (error) {
    console.error('Allocation rejection error:', error);

    return res.status(500).json({
      message: 'Unable to reject allocation.',
    });
  }
};

// GET /api/donations/my-allocations
// Only the owning NGO can retrieve its pickup codes.
exports.getMyAllocations = async (req, res) => {
  try {
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
      .populate('donationId', 'title description imageUrl address pickupWindowStart pickupWindowEnd')
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

// POST /api/donations/allocations/:allocationId/verify-pickup
// Only the original donor verifies the NGO's pickup code.
exports.verifyPickupCode = async (req, res) => {
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

    const allocation = await Allocation.findOne({
      _id: allocationId,
      donorId: req.user._id,
      status: 'approved',
    }).select('+pickupCode');

    if (!allocation) {
      return res.status(404).json({
        message: 'No active allocation found.',
      });
    }

    if (allocation.pickupCode !== code) {
      return res.status(400).json({
        message: 'Incorrect pickup code.',
      });
    }

    const updatedAllocation = await Allocation.findOneAndUpdate(
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
      { new: true }
    );

    if (!updatedAllocation) {
      return res.status(409).json({
        message: 'Allocation has already been collected or changed.',
      });
    }

    // Mark the donation collected only when every allocated portion
    // has been collected and no portions remain available.
    const donation = await Donation.findById(
      allocation.donationId
    );

    if (donation && donation.remainingPortions === 0) {
      const otherApproved = await Allocation.exists({
        donationId: donation._id,
        status: 'approved',
      });

      if (!otherApproved) {
        await Donation.updateOne(
          {
            _id: donation._id,
            remainingPortions: 0,
          },
          {
            $set: { status: 'collected' },
          }
        );
      }
    }

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

    return res.status(500).json({
      message: 'Unable to verify pickup code.',
    });
  }
};

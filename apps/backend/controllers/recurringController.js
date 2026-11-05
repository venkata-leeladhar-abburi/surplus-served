const mongoose = require('mongoose');
const RecurringTemplate = require('../models/RecurringTemplate');
const Donation = require('../models/Donation');

const FOOD_CATEGORIES = Donation.schema.path('foodCategory').enumValues;
const DIET_TYPES = ['veg', 'non_veg'];
const MAX_TEMPLATES_PER_DONOR = 20;

// "Today" for the daily confirm/skip, in India time (the app's users).
const todayKey = (now = new Date()) =>
  now.toLocaleDateString('en-CA', { timeZone: 'Asia/Kolkata' });

const toResponse = (template, today = todayKey()) => {
  const t = template.toObject ? template.toObject() : template;
  return {
    ...t,
    confirmedToday: t.lastConfirmedOn === today,
    skippedToday: t.lastSkippedOn === today,
  };
};

const badRequest = (res, message) => res.status(400).json({ message });

// Shared by create and update. Returns { values } or { error }.
const readTemplateFields = (body, { partial }) => {
  const values = {};

  if (!partial || body.title !== undefined) {
    if (typeof body.title !== 'string' || !body.title.trim()) {
      return { error: 'Please enter what food you usually donate.' };
    }
    if (body.title.trim().length > 100) {
      return { error: 'Food name must be 100 characters or fewer.' };
    }
    values.title = body.title.trim();
  }

  if (!partial || body.locality !== undefined) {
    if (typeof body.locality !== 'string' || !body.locality.trim()) {
      return { error: 'Please enter the pickup locality.' };
    }
    if (body.locality.trim().length > 100) {
      return { error: 'Locality must be 100 characters or fewer.' };
    }
    values.locality = body.locality.trim();
  }

  if (!partial || body.portions !== undefined) {
    const portions = Number(body.portions);
    if (!Number.isInteger(portions) || portions < 1 || portions > 1000) {
      return { error: 'Portions must be a whole number from 1 to 1000.' };
    }
    values.portions = portions;
  }

  if (!partial || body.windowHours !== undefined) {
    const hours = Number(body.windowHours);
    if (!Number.isInteger(hours) || hours < 1 || hours > 12) {
      return { error: 'Pickup window must be 1 to 12 hours.' };
    }
    values.windowHours = hours;
  }

  if (!partial || body.safeHours !== undefined) {
    // Defaults to the pickup window if not given.
    const raw = body.safeHours ?? values.windowHours;
    const hours = Number(raw);
    if (!Number.isInteger(hours) || hours < 1 || hours > 72) {
      return { error: 'Safe-to-eat time must be 1 to 72 hours.' };
    }
    values.safeHours = hours;
  }

  if (body.foodCategory !== undefined) {
    if (!FOOD_CATEGORIES.includes(body.foodCategory)) {
      return { error: 'Invalid food category.' };
    }
    values.foodCategory = body.foodCategory;
  }

  if (body.dietType !== undefined) {
    if (body.dietType !== null && !DIET_TYPES.includes(body.dietType)) {
      return { error: 'Invalid diet type. Use veg or non_veg.' };
    }
    values.dietType = body.dietType;
  }

  if (body.active !== undefined) {
    if (typeof body.active !== 'boolean') {
      return { error: 'active must be true or false.' };
    }
    values.active = body.active;
  }

  return { values };
};

// GET /api/recurring
exports.getMyTemplates = async (req, res) => {
  try {
    const templates = await RecurringTemplate.find({ donorId: req.user._id })
      .sort({ createdAt: -1 })
      .lean();
    const today = todayKey();

    return res.status(200).json({
      count: templates.length,
      templates: templates.map((t) => toResponse(t, today)),
    });
  } catch (error) {
    console.error('Get recurring templates error:', error);
    return res.status(500).json({ message: 'Unable to load recurring donations.' });
  }
};

// POST /api/recurring
exports.createTemplate = async (req, res) => {
  try {
    const { values, error } = readTemplateFields(req.body || {}, { partial: false });
    if (error) return badRequest(res, error);

    if (values.safeHours < values.windowHours) {
      return badRequest(
        res,
        'The food must stay safe to eat until the end of the pickup window.'
      );
    }

    const existing = await RecurringTemplate.countDocuments({ donorId: req.user._id });
    if (existing >= MAX_TEMPLATES_PER_DONOR) {
      return badRequest(
        res,
        `You can have at most ${MAX_TEMPLATES_PER_DONOR} recurring donations.`
      );
    }

    const template = await RecurringTemplate.create({
      ...values,
      donorId: req.user._id,
      active: true,
    });

    return res.status(201).json({ template: toResponse(template) });
  } catch (error) {
    console.error('Create recurring template error:', error);
    return res.status(500).json({ message: 'Unable to save recurring donation.' });
  }
};

const findOwnTemplate = async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    badRequest(res, 'Invalid recurring donation ID.');
    return null;
  }

  const template = await RecurringTemplate.findOne({
    _id: id,
    donorId: req.user._id,
  });

  if (!template) {
    res.status(404).json({ message: 'Recurring donation not found.' });
    return null;
  }

  return template;
};

// PATCH /api/recurring/:id  (edit fields or pause/resume with { active })
exports.updateTemplate = async (req, res) => {
  try {
    const template = await findOwnTemplate(req, res);
    if (!template) return undefined;

    const { values, error } = readTemplateFields(req.body || {}, { partial: true });
    if (error) return badRequest(res, error);

    const windowHours = values.windowHours ?? template.windowHours;
    const safeHours = values.safeHours ?? template.safeHours;
    if (safeHours < windowHours) {
      return badRequest(
        res,
        'The food must stay safe to eat until the end of the pickup window.'
      );
    }

    template.set(values);
    await template.save();

    return res.status(200).json({ template: toResponse(template) });
  } catch (error) {
    console.error('Update recurring template error:', error);
    return res.status(500).json({ message: 'Unable to update recurring donation.' });
  }
};

// DELETE /api/recurring/:id  (donations already posted are not affected)
exports.deleteTemplate = async (req, res) => {
  try {
    const template = await findOwnTemplate(req, res);
    if (!template) return undefined;

    await template.deleteOne();

    return res.status(200).json({ message: 'Recurring donation deleted.' });
  } catch (error) {
    console.error('Delete recurring template error:', error);
    return res.status(500).json({ message: 'Unable to delete recurring donation.' });
  }
};

// POST /api/recurring/:id/confirm  { portions? }
// Posts today's donation from the template: pickup window starts now.
exports.confirmToday = async (req, res) => {
  try {
    const template = await findOwnTemplate(req, res);
    if (!template) return undefined;

    if (!template.active) {
      return res.status(409).json({ message: 'This recurring donation is paused.' });
    }

    let portions = template.portions;
    if (req.body && req.body.portions !== undefined) {
      portions = Number(req.body.portions);
      if (!Number.isInteger(portions) || portions < 1 || portions > 1000) {
        return badRequest(res, 'Portions must be a whole number from 1 to 1000.');
      }
    }

    const today = todayKey();

    // Claim today atomically so a double tap can't post twice.
    const claimed = await RecurringTemplate.findOneAndUpdate(
      {
        _id: template._id,
        donorId: req.user._id,
        active: true,
        lastConfirmedOn: { $ne: today },
        lastSkippedOn: { $ne: today },
      },
      { $set: { lastConfirmedOn: today } },
      { new: true }
    );

    if (!claimed) {
      return res.status(409).json({
        message: 'Today was already confirmed or skipped for this donation.',
      });
    }

    const now = new Date();
    const hour = 60 * 60 * 1000;

    let donation;
    try {
      donation = await Donation.create({
        donorId: req.user._id,
        donorName: req.user.name,
        title: claimed.title,
        portions,
        remainingPortions: portions,
        pickupWindowStart: now,
        pickupWindowEnd: new Date(now.getTime() + claimed.windowHours * hour),
        expiresAt: new Date(now.getTime() + claimed.safeHours * hour),
        foodCategory: claimed.foodCategory,
        dietType: claimed.dietType,
        address: { locality: claimed.locality },
        status: 'available',
      });
    } catch (createError) {
      // Release today's claim so the donor can try again.
      await RecurringTemplate.updateOne(
        { _id: claimed._id, lastConfirmedOn: today },
        { $set: { lastConfirmedOn: template.lastConfirmedOn } }
      );
      throw createError;
    }

    claimed.lastDonationId = donation._id;
    await claimed.save();

    return res.status(201).json({
      message: "Today's donation is posted.",
      template: toResponse(claimed, today),
      donation,
    });
  } catch (error) {
    console.error('Confirm recurring donation error:', error);
    return res.status(500).json({ message: "Unable to post today's donation." });
  }
};

// POST /api/recurring/:id/skip
exports.skipToday = async (req, res) => {
  try {
    const template = await findOwnTemplate(req, res);
    if (!template) return undefined;

    const today = todayKey();

    const updated = await RecurringTemplate.findOneAndUpdate(
      {
        _id: template._id,
        donorId: req.user._id,
        lastConfirmedOn: { $ne: today },
        lastSkippedOn: { $ne: today },
      },
      { $set: { lastSkippedOn: today } },
      { new: true }
    );

    if (!updated) {
      return res.status(409).json({
        message: 'Today was already confirmed or skipped for this donation.',
      });
    }

    return res.status(200).json({ template: toResponse(updated, today) });
  } catch (error) {
    console.error('Skip recurring donation error:', error);
    return res.status(500).json({ message: 'Unable to skip today.' });
  }
};

exports._todayKey = todayKey;

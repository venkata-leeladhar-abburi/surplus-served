
const multer = require('multer');
const crypto = require('crypto');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

const allowedMimeTypes = [
  'image/jpeg',
  'image/png',
  'image/webp',
];

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'surplus-served/food-donations',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
    public_id: () => crypto.randomUUID(),
  },
});

const fileFilter = (req, file, cb) => {
  if (!allowedMimeTypes.includes(file.mimetype)) {
    return cb(
      new Error('Only JPG, PNG and WEBP images are allowed.')
    );
  }

  cb(null, true);
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
  },
});

module.exports = upload;

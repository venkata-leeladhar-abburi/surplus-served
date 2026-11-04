const multer = require('multer');

const allowedMimeTypes = [
  'image/jpeg',
  'image/png',
  'application/pdf',
];

const fileFilter = (req, file, cb) => {
  if (!allowedMimeTypes.includes(file.mimetype)) {
    return cb(
      new Error('Only JPG, PNG and PDF certificates are allowed.')
    );
  }

  cb(null, true);
};

const certificateUpload = multer({
  storage: multer.memoryStorage(),
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

module.exports = certificateUpload;

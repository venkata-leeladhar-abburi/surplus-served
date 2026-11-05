
const multer = require('multer');

const allowedMimeTypes = [
  'image/jpeg',
  'image/png',
  'application/pdf',
];

const fileFilter = (req, file, cb) => {
  if (!allowedMimeTypes.includes(file.mimetype)) {
    const error = new Error('Only JPG, PNG and PDF certificates are allowed.');
    error.status = 400;
    return cb(error);
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


const multer = require('multer');

const allowedMimeTypes = [
  'image/jpeg',
  'image/png',
  'application/pdf',
];

const fileFilter = (req, file, cb) => {
  // Temporary debugging: identify the actual MIME type sent by Flutter.
  console.log('Certificate upload details:', {
    originalname: file.originalname,
    mimetype: file.mimetype,
  });

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

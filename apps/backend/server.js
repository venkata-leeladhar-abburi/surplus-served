
const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const multer = require('multer');

const connectDB = require('./config/db');

dotenv.config();

connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Surplus to Serve API is running.',
  });
});

// API Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/donations', require('./routes/donationRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/recurring', require('./routes/recurringRoutes'));

// Handle unknown routes
app.use((req, res) => {
  res.status(404).json({
    message: 'API route not found.',
  });
});

// Handle errors, including malformed JSON
app.use((err, req, res, next) => {
  console.error('Server error:', err);

  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      message: 'Invalid JSON request body.',
    });
  }

  // File upload problems (wrong type, too large) are the client's to fix.
  if (err instanceof multer.MulterError) {
    return res.status(400).json({
      message:
        err.code === 'LIMIT_FILE_SIZE'
          ? 'File must be 5 MB or smaller.'
          : 'Invalid file upload.',
    });
  }

  if (err.status === 400) {
    return res.status(400).json({
      message: err.message,
    });
  }

  return res.status(500).json({
    message: 'Internal server error.',
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

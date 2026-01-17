const express = require('express');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/v1/ai', require('./routes/aiRoutes'));

// Test route
app.get('/', (req, res) => {
  res.send('Backend is Live!');
});

// Server
app.listen(3000, '0.0.0.0', () => {
  console.log('Server is running on http://0.0.0.0:3000');
});
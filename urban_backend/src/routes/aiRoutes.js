// urban-backend/src/routes/aiRoutes.js
const express = require('express');
const router = express.Router();
const axios = require('axios');
require('dotenv').config();

router.post('/citybrain', async (req, res) => {
  try {
    const { question } = req.body;
    const response = await axios.post(`${process.env.PYTHON_AI_URL}/citybrain`, { question });
    res.json(response.data);
  } catch (error) {
    console.error('AI Engine Error:', error.message);
    res.status(500).json({ error: "CityBrain AI is offline" });
  }
});

module.exports = router;
// urban-backend/src/controllers/aiController.js
const axios = require('axios');
require('dotenv').config();

// Get Python AI URL from .env
const PYTHON_AI_URL = process.env.PYTHON_AI_URL || 'http://localhost:8000';

exports.askCityBrain = async (req, res) => {
  try {
    const { question, context } = req.body;

    // Validate input
    if (!question || typeof question !== 'string') {
      return res.status(400).json({
        error: "Invalid input: 'question' is required (string)"
      });
    }

    // Call Python AI Engine
    const aiResponse = await axios.post(`${PYTHON_AI_URL}/citybrain`, {
      question,
      context: context || {}
    });

    // Return AI response to Flutter
    res.json({
      success: true,
      data: aiResponse.data
    });

  } catch (error) {
    console.error('AI Engine Error:', error.message);
    
    // Fallback if AI is down
    if (error.code === 'ECONNREFUSED') {
      res.status(503).json({
        success: false,
        error: "CityBrain AI is temporarily offline",
        fallback: "Try again in 30 seconds"
      });
    } else {
      res.status(500).json({
        success: false,
        error: "AI processing failed"
      });
    }
  }
};
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

app.use(cors());
app.use(express.json());

// 1. Health Check Route
app.get('/', (req, res) => {
    res.send("🚀 Urban Super-System Backend is LIVE!");
});

// 2. Main AI Route (Flutter isi ko call karega)
app.post('/api/v1/ai/citybrain', async (req, res) => {
    const userQuestion = req.body.question;
    console.log("Question received from Flutter:", userQuestion);

    try {
        // [COMMENT: Node.js ab Python Analytics server (Port 8000) ko call kar raha hai]
        const pythonRes = await axios.get(`http://127.0.0.1:8000/analyze?q=${encodeURIComponent(userQuestion)}`);

        // Python se aaya hua data Flutter ko wapas bhej raha hai
        res.json({ "answer": pythonRes.data.result });
    } catch (e) {
        console.error("Error communicating with Python:", e.message);
        res.status(500).json({ "answer": "❌ Backend is working, but Python AI engine is not responding." });
    }
});

// Port 3000 par '0.0.0.0' ke saath listen karna taaki aapka Flutter connect ho sake
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Backend listening at http://0.0.0.0:${PORT}`);
});
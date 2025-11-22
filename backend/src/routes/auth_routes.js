const express = require('express');
const { login } = require('../controllers/auth_controller');

// ✅ USAR express.Router() explícitamente
const router = express.Router();
router.post('/login', login);

module.exports = router;
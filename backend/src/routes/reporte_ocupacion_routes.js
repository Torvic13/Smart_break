// src/routes/reporte_ocupacion_routes.js
const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middlewares/auth_middleware');
const { crearReporte } = require('../controllers/reporte_ocupacion_controller');

// POST /api/v1/reportes
router.post('/', requireAuth, crearReporte);

module.exports = router;
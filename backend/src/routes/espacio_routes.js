// src/routes/espacio_routes.js
const express = require('express');
const {
  listarEspacios,
  crearEspacio,
  obtenerEspacio,
  obtenerEspaciosDisponibles,
} = require('../controllers/espacio_controller');

const router = express.Router();

// GET /api/v1/espacios
router.get('/', listarEspacios);

// GET /api/v1/espacios/disponibles
router.get('/disponibles', obtenerEspaciosDisponibles);

// GET /api/v1/espacios/:idEspacio
router.get('/:idEspacio', obtenerEspacio);

// POST /api/v1/espacios  (solo admin)
router.post('/', crearEspacio);

module.exports = router;

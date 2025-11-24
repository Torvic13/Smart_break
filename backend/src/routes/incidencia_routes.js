// src/routes/incidencia_routes.js
const express = require('express');
const router = express.Router();
const {
  obtenerIncidenciasEspacio,
  listarIncidencias,
  crearIncidencia,
  resolverIncidencia,
  eliminarIncidencia,
  obtenerIncidenciasUsuario,
} = require('../controllers/incidencia_controller');
const { requireAuth, requireRole } = require('../middlewares/auth_middleware');

// Rutas específicas primero (para evitar conflictos con parámetros dinámicos)
router.get('/espacio/:idEspacio', obtenerIncidenciasEspacio);
router.get('/usuario/:idUsuario', requireAuth, obtenerIncidenciasUsuario);

// Rutas con parámetros dinámicos
router.patch('/:idIncidencia/resolver', requireAuth, requireRole('admin'), resolverIncidencia);
router.delete('/:idIncidencia', requireAuth, requireRole('admin'), eliminarIncidencia);

// Rutas base
router.post('/', crearIncidencia);
router.get('/', requireAuth, requireRole('admin'), listarIncidencias);

module.exports = router;

const express = require('express');
const {
  listarCalificacionesPorEspacio,
  crearCalificacion,
} = require('../controllers/calificacion_controller');
const { requireAuth, requireRole } = require('../middlewares/auth_middleware');

const router = express.Router();

// Todas las rutas aquí cuelgan de /api/v1
// Ej: GET /api/v1/espacios/:idEspacio/calificaciones
router.get('/espacios/:idEspacio/calificaciones', listarCalificacionesPorEspacio);

// Crear calificación -> requiere estar logueado (estudiante o admin)
router.post(
  '/espacios/:idEspacio/calificaciones',
  requireAuth,
  requireRole('estudiante', 'admin'),
  crearCalificacion
);

module.exports = router;

const express = require('express');

const {
  listarTodasCalificaciones,
  listarCalificacionesPorEspacio,
  crearCalificacion,
  actualizarCalificacion,
  eliminarCalificacion,
} = require('../controllers/calificacion_controller');
const { requireAuth, requireRole } = require('../middlewares/auth_middleware');

const router = express.Router();

// GET /api/v1/calificaciones  (solo admin, para la pantalla "Gestionar Comentarios")
router.get(
  '/calificaciones',
  requireAuth,
  requireRole('admin'),
  listarTodasCalificaciones
);

// GET /api/v1/espacios/:idEspacio/calificaciones
router.get(
  '/espacios/:idEspacio/calificaciones',
  requireAuth,
  listarCalificacionesPorEspacio
);

// POST /api/v1/espacios/:idEspacio/calificaciones
router.post(
  '/espacios/:idEspacio/calificaciones',
  requireAuth,
  requireRole('estudiante', 'admin'),
  crearCalificacion
);

// PUT /api/v1/calificaciones/:idCalificacion
router.put(
  '/calificaciones/:idCalificacion',
  requireAuth,
  requireRole('estudiante', 'admin'),
  actualizarCalificacion
);

// DELETE /api/v1/calificaciones/:idCalificacion
router.delete(
  '/calificaciones/:idCalificacion',
  requireAuth,
  requireRole('estudiante', 'admin'),
  eliminarCalificacion
);

module.exports = router;

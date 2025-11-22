const express = require('express');
const {
  obtenerCalificacionesPorUsuario,
  obtenerCalificacionesPorEspacio,
  crearCalificacion,
  actualizarCalificacion,
  eliminarCalificacion,
} = require('../controllers/calificacion_controller');
const { requireAuth } = require('../middlewares/auth_middleware');

// ✅ USAR express.Router() explícitamente
const router = express.Router();

// Obtener calificaciones por usuario
router.get('/usuarios/:idUsuario', obtenerCalificacionesPorUsuario);

// Obtener calificaciones por espacio
router.get('/espacios/:idEspacio', obtenerCalificacionesPorEspacio);

// Crear o actualizar calificación (requiere autenticación)
router.post('/', requireAuth, crearCalificacion);

// Actualizar calificación específica (requiere autenticación)
router.put('/:idCalificacion', requireAuth, actualizarCalificacion);

// Eliminar calificación (requiere autenticación)
router.delete('/:idCalificacion', requireAuth, eliminarCalificacion);

module.exports = router;
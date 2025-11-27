// src/routes/espacio_routes.js
const express = require('express');
const {
  listarEspacios,
  crearEspacio,
  obtenerEspacio,
  actualizarEspacio,
  eliminarEspacio,
  registrarOcupacion,     // 👈 si ya lo tienes
  liberarOcupacion,       // 👈 si ya lo tienes
  reiniciarOcupacionGlobal, // 👈 NUEVO
} = require('../controllers/espacio_controller');
const { requireAuth, requireRole } = require('../middlewares/auth_middleware');

const router = express.Router();

// Cualquier usuario puede ver los espacios (si quieres puedes poner requireAuth)
router.get('/', listarEspacios);

// Ver detalle de un espacio por idEspacio
router.get('/:idEspacio', obtenerEspacio);

// Solo admin puede crear espacios nuevos
router.post('/', requireAuth, requireRole('admin'), crearEspacio);

// Solo admin puede actualizar espacios
router.put('/:idEspacio', requireAuth, requireRole('admin'), actualizarEspacio);

// Solo admin puede eliminar espacios
router.delete(
  '/:idEspacio',
  requireAuth,
  requireRole('admin'),
  eliminarEspacio
);

// 👇 Rutas de ocupación por espacio (si ya las tienes)
router.post(
  '/:idEspacio/ocupar',
  requireAuth,
  registrarOcupacion
);
router.post(
  '/:idEspacio/liberar',
  requireAuth,
  liberarOcupacion
);

// 👇 NUEVA ruta global para admin: reiniciar ocupación de todos los espacios
router.post(
  '/reset-ocupacion',
  requireAuth,
  requireRole('admin'),
  reiniciarOcupacionGlobal
);

module.exports = router;
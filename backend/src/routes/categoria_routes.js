// src/routes/categoria_routes.js
const express = require('express');
const {
  listarCategorias,
  obtenerCategoria,
  crearCategoria,
  actualizarCategoria,
  eliminarCategoria,
} = require('../controllers/categoria_controller');
const { requireAuth, requireRole } = require('../middlewares/auth_middleware');

const router = express.Router();

// GET /api/v1/categorias - Ver todas las categorías (público)
router.get('/', listarCategorias);

// GET /api/v1/categorias/:idCategoria - Ver detalle (público)
router.get('/:idCategoria', obtenerCategoria);

// POST /api/v1/categorias - Crear categoría (solo admin)
router.post('/', requireAuth, requireRole('admin'), crearCategoria);

// PUT /api/v1/categorias/:idCategoria - Actualizar (solo admin)
router.put('/:idCategoria', requireAuth, requireRole('admin'), actualizarCategoria);

// DELETE /api/v1/categorias/:idCategoria - Eliminar/desactivar (solo admin)
router.delete('/:idCategoria', requireAuth, requireRole('admin'), eliminarCategoria);

module.exports = router;

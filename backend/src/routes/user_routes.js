const express = require('express');
const { 
  crearUsuario, 
  listarUsuarios, 
  buscarPorCodigo, 
  agregarAmigo, 
  obtenerAmigos 
} = require('../controllers/user_controller');

const router = express.Router();

// GET /api/v1/usuarios
router.get('/', listarUsuarios);

// POST /api/v1/usuarios
router.post('/', crearUsuario);

// GET /api/v1/usuarios/buscar/:codigoAlumno
router.get('/buscar/:codigoAlumno', buscarPorCodigo);

// POST /api/v1/usuarios/:idUsuario/amigos
router.post('/:idUsuario/amigos', agregarAmigo);

// GET /api/v1/usuarios/:idUsuario/amigos
router.get('/:idUsuario/amigos', obtenerAmigos);

module.exports = router;

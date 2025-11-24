// src/controllers/incidencia_controller.js
const Incidencia = require('../models/incidencia_model');
const Espacio = require('../models/espacio_model');

// GET /api/v1/incidencias/espacio/:idEspacio (obtener incidencias no resueltas de un espacio)
async function obtenerIncidenciasEspacio(req, res) {
  try {
    const { idEspacio } = req.params;

    // Validar que el espacio existe
    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    // Obtener incidencias no resueltas
    const incidencias = await Incidencia.find({
      idEspacio,
      resuelta: false,
    }).sort({ fechaReporte: -1 });

    return res.json(incidencias);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al obtener incidencias del espacio',
      error: err.message,
    });
  }
}

// GET /api/v1/incidencias (obtener todas las incidencias - solo admin)
async function listarIncidencias(req, res) {
  try {
    const incidencias = await Incidencia.find()
      .sort({ fechaReporte: -1 });

    return res.json(incidencias);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al listar incidencias',
      error: err.message,
    });
  }
}

// POST /api/v1/incidencias (crear nueva incidencia)
async function crearIncidencia(req, res) {
  try {
    const { idEspacio, tipoIncidencia, descripcion } = req.body;
    const usuarioReporte = req.user?.sub || 'usuario-anonimo'; // Del token JWT o anónimo

    if (!idEspacio || !tipoIncidencia || !descripcion) {
      return res.status(400).json({
        message: 'idEspacio, tipoIncidencia y descripcion son obligatorios',
      });
    }

    // Validar que el espacio existe
    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    // Crear la incidencia
    const nueva = await Incidencia.create({
      idEspacio,
      nombreEspacio: espacio.nombre,
      tipoIncidencia,
      descripcion,
      usuarioReporte,
    });

    return res.status(201).json({
      message: 'Incidencia reportada exitosamente',
      incidencia: nueva,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al crear incidencia',
      error: err.message,
    });
  }
}

// PATCH /api/v1/incidencias/:idIncidencia/resolver (resolver una incidencia - solo admin)
async function resolverIncidencia(req, res) {
  try {
    const { idIncidencia } = req.params;
    const { notas } = req.body;

    const incidencia = await Incidencia.findOne({ idIncidencia });
    if (!incidencia) {
      return res.status(404).json({ message: 'Incidencia no encontrada' });
    }

    incidencia.resuelta = true;
    incidencia.fechaResolucion = new Date();
    if (notas) {
      incidencia.notas = notas;
    }

    await incidencia.save();

    return res.json({
      message: 'Incidencia resuelta',
      incidencia,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al resolver incidencia',
      error: err.message,
    });
  }
}

// DELETE /api/v1/incidencias/:idIncidencia (eliminar una incidencia - solo admin)
async function eliminarIncidencia(req, res) {
  try {
    const { idIncidencia } = req.params;

    const resultado = await Incidencia.deleteOne({ idIncidencia });

    if (resultado.deletedCount === 0) {
      return res.status(404).json({ message: 'Incidencia no encontrada' });
    }

    return res.json({ message: 'Incidencia eliminada' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al eliminar incidencia',
      error: err.message,
    });
  }
}

// GET /api/v1/incidencias/usuario/:idUsuario (obtener incidencias reportadas por un usuario)
async function obtenerIncidenciasUsuario(req, res) {
  try {
    const { idUsuario } = req.params;

    const incidencias = await Incidencia.find({
      usuarioReporte: idUsuario,
    }).sort({ fechaReporte: -1 });

    return res.json(incidencias);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al obtener incidencias del usuario',
      error: err.message,
    });
  }
}

module.exports = {
  obtenerIncidenciasEspacio,
  listarIncidencias,
  crearIncidencia,
  resolverIncidencia,
  eliminarIncidencia,
  obtenerIncidenciasUsuario,
};

// src/controllers/espacio_controller.js
const Espacio = require('../models/espacio_model');

// GET /api/v1/espacios
async function listarEspacios(_req, res) {
  try {
    const espacios = await Espacio.find().sort({ nombre: 1 });
    return res.json(espacios);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al listar espacios',
      error: err.message,
    });
  }
}

// POST /api/v1/espacios
async function crearEspacio(req, res) {
  try {
    const {
      idEspacio,
      nombre,
      tipo,
      descripcion = "",
      capacidad = 0,
      nivelOcupacion = 'vacio',
      promedioCalificacion = 0,
      ubicacion,
      caracteristicas = [],
      categoriaIds = [],
    } = req.body;

    if (!nombre || !tipo || !ubicacion?.latitud || !ubicacion?.longitud) {
      return res.status(400).json({
        message: 'nombre, tipo y ubicacion (latitud, longitud) son obligatorios',
      });
    }

    const nuevo = await Espacio.create({
      idEspacio, // SI VIENE DESDE FLUTTER SE USA
      nombre,
      tipo,
      descripcion,
      capacidad,
      nivelOcupacion,
      promedioCalificacion,
      ubicacion,
      caracteristicas,
      categoriaIds,
    });

    return res.status(201).json(nuevo);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al crear espacio',
      error: err.message,
    });
  }
}

// GET /api/v1/espacios/:idEspacio
async function obtenerEspacio(req, res) {
  try {
    const { idEspacio } = req.params;

    const espacio = await Espacio.findOne({ idEspacio });

    if (!espacio) {
      return res.status(404).json({
        message: 'Espacio no encontrado',
      });
    }

    return res.json(espacio);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al obtener espacio',
      error: err.message,
    });
  }
}

// GET /api/v1/espacios/disponibles
async function obtenerEspaciosDisponibles(_req, res) {
  try {
    const espacios = await Espacio.find().sort({ nombre: 1 });

    const disponibles = espacios.filter(
      (e) => e.nivelOcupacion !== 'lleno'
    );

    return res.json(disponibles);
  } catch (err) {
    console.error(err);
    return res.status(500).json({
      message: 'Error al obtener espacios disponibles',
      error: err.message,
    });
  }
}

module.exports = {
  listarEspacios,
  crearEspacio,
  obtenerEspacio,
  obtenerEspaciosDisponibles,
};

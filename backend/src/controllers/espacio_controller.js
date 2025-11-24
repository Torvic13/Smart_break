// src/controllers/espacio_controller.js
const Espacio = require('../models/espacio_model');

// GET /api/v1/espacios
async function listarEspacios(_req, res) {
  try {
    const espacios = await Espacio.find().sort({ nombre: 1 });
    return res.json(espacios);
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al listar espacios', error: err.message });
  }
}

// POST /api/v1/espacios  (solo admin)
async function crearEspacio(req, res) {
  try {
    const {
      nombre,
      tipo,
      nivelOcupacion = 'vacio',
      promedioCalificacion = 0,
      ubicacion,
      caracteristicas = [],
      categoriaIds = [],
    } = req.body;

    if (!nombre || !tipo || !ubicacion?.latitud || !ubicacion?.longitud) {
      return res.status(400).json({
        message:
          'nombre, tipo y ubicacion (latitud, longitud) son obligatorios',
      });
    }

    const nuevo = await Espacio.create({
      nombre,
      tipo,
      nivelOcupacion,
      promedioCalificacion,
      ubicacion,
      caracteristicas,
      categoriaIds,
    });

    return res
      .status(201)
      .json({ message: 'Espacio creado', espacio: nuevo.toJSON() });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al crear espacio', error: err.message });
  }
}

// (Opcional) GET /api/v1/espacios/:idEspacio
async function obtenerEspacio(req, res) {
  try {
    const { idEspacio } = req.params;
    const espacio = await Espacio.findOne({ idEspacio });

    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    return res.json(espacio);
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al obtener espacio', error: err.message });
  }
}

// PUT /api/v1/espacios/:idEspacio
async function actualizarEspacio(req, res) {
  try {
    const { idEspacio } = req.params;
    const datosActualizados = req.body;

    const espacio = await Espacio.findOneAndUpdate(
      { idEspacio },
      datosActualizados,
      { new: true, runValidators: true }
    );

    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    return res.json({ message: 'Espacio actualizado', espacio });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al actualizar espacio', error: err.message });
  }
}

// DELETE /api/v1/espacios/:idEspacio
async function eliminarEspacio(req, res) {
  try {
    const { idEspacio } = req.params;
    const espacio = await Espacio.findOneAndDelete({ idEspacio });

    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    return res.json({ message: 'Espacio eliminado', espacio });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al eliminar espacio', error: err.message });
  }
}

module.exports = { 
  listarEspacios, 
  crearEspacio, 
  obtenerEspacio, 
  actualizarEspacio, 
  eliminarEspacio 
};

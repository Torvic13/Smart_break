// src/controllers/espacio_controller.js
const Espacio = require('../models/espacio_model');

// ================================================================
// Helper para calcular nivelOcupacion según porcentaje
// ================================================================
function calcularNivelOcupacion(ocupacionActual, aforoMaximo) {
  if (!aforoMaximo || aforoMaximo <= 0) return 'vacio';
  if (ocupacionActual <= 0) return 'vacio';

  const ratio = ocupacionActual / aforoMaximo;

  if (ratio <= 0.25) return 'bajo';
  if (ratio <= 0.60) return 'medio';
  if (ratio <= 0.90) return 'alto';
  return 'lleno';
}

// ================================================================
// CRUD BÁSICO
// ================================================================
exports.listarEspacios = async (_req, res) => {
  try {
    const espacios = await Espacio.find({});
    res.json(espacios);
  } catch (err) {
    console.error('Error listando espacios:', err);
    res.status(500).json({ error: 'Error al listar espacios' });
  }
};

exports.crearEspacio = async (req, res) => {
  try {
    const espacio = new Espacio(req.body);
    await espacio.save();
    res.status(201).json(espacio);
  } catch (err) {
    console.error('Error creando espacio:', err);
    res.status(400).json({ error: 'Error al crear espacio', detalle: err.message });
  }
};

exports.obtenerEspacio = async (req, res) => {
  try {
    const { idEspacio } = req.params;

    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ error: 'Espacio no encontrado' });
    }

    res.json(espacio);
  } catch (err) {
    console.error('Error obteniendo espacio:', err);
    res.status(500).json({ error: 'Error al obtener espacio' });
  }
};

exports.actualizarEspacio = async (req, res) => {
  try {
    const { idEspacio } = req.params;

    const espacio = await Espacio.findOneAndUpdate(
      { idEspacio },
      req.body,
      { new: true }
    );

    if (!espacio) {
      return res.status(404).json({ error: 'Espacio no encontrado' });
    }

    res.json(espacio);
  } catch (err) {
    console.error('Error actualizando espacio:', err);
    res.status(400).json({ error: 'Error al actualizar espacio', detalle: err.message });
  }
};

exports.eliminarEspacio = async (req, res) => {
  try {
    const { idEspacio } = req.params;

    const result = await Espacio.deleteOne({ idEspacio });
    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Espacio no encontrado' });
    }

    res.json({ ok: true, message: 'Espacio eliminado' });
  } catch (err) {
    console.error('Error eliminando espacio:', err);
    res.status(500).json({ error: 'Error al eliminar espacio' });
  }
};

// ================================================================
// OCUPAR ESPACIO
// ================================================================
exports.registrarOcupacion = async (req, res) => {
  try {
    const { idEspacio } = req.params;

    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ error: 'Espacio no encontrado' });
    }

    // Si no está definido, inicializamos en 0
    if (typeof espacio.ocupacionActual !== 'number') {
      espacio.ocupacionActual = 0;
    }

    // Validar aforo
    if (espacio.ocupacionActual >= espacio.aforoMaximo) {
      return res.status(400).json({ error: 'El espacio ya está al 100% de su aforo' });
    }

    espacio.ocupacionActual += 1;

    espacio.nivelOcupacion = calcularNivelOcupacion(
      espacio.ocupacionActual,
      espacio.aforoMaximo
    );

    await espacio.save();

    res.json({
      ok: true,
      message: 'Ocupación registrada',
      ocupacionActual: espacio.ocupacionActual,
      aforoMaximo: espacio.aforoMaximo,
      nivelOcupacion: espacio.nivelOcupacion,
      espacio,
    });
  } catch (err) {
    console.error('Error registrando ocupación:', err);
    res.status(500).json({ error: 'Error al registrar ocupación' });
  }
};

// ================================================================
// LIBERAR ESPACIO
// ================================================================
exports.liberarOcupacion = async (req, res) => {
  try {
    const { idEspacio } = req.params;

    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ error: 'Espacio no encontrado' });
    }

    if (typeof espacio.ocupacionActual !== 'number') {
      espacio.ocupacionActual = 0;
    }

    // No bajamos más de 0
    if (espacio.ocupacionActual > 0) {
      espacio.ocupacionActual -= 1;
    }

    espacio.nivelOcupacion = calcularNivelOcupacion(
      espacio.ocupacionActual,
      espacio.aforoMaximo
    );

    await espacio.save();

    res.json({
      ok: true,
      message: 'Ocupación liberada',
      ocupacionActual: espacio.ocupacionActual,
      aforoMaximo: espacio.aforoMaximo,
      nivelOcupacion: espacio.nivelOcupacion,
      espacio,
    });
  } catch (err) {
    console.error('Error liberando ocupación:', err);
    res.status(500).json({ error: 'Error al liberar ocupación' });
  }
};
// ===================== REINICIAR OCUPACIÓN GLOBAL =====================

exports.reiniciarOcupacionGlobal = async (_req, res) => {
  try {
    // Pone ocupacionActual = 0 y nivelOcupacion = 'vacio' en todos los documentos
    const result = await Espacio.updateMany(
      {},
      {
        $set: {
          ocupacionActual: 0,
          nivelOcupacion: 'vacio',
        },
      }
    );

    res.json({
      ok: true,
      message: 'Ocupación reiniciada en todos los espacios',
      modificados: result.modifiedCount ?? result.nModified,
    });
  } catch (err) {
    console.error('Error reiniciando ocupación global:', err);
    res
      .status(500)
      .json({ error: 'Error al reiniciar ocupación de los espacios' });
  }
};
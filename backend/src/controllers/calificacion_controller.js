const Calificacion = require('../models/calificacion_model');
const Espacio = require('../models/espacio_model');

// GET /api/v1/espacios/:idEspacio/calificaciones
async function listarCalificacionesPorEspacio(req, res) {
  try {
    const { idEspacio } = req.params;

    const calificaciones = await Calificacion
      .find({ idEspacio })
      .sort({ fechaCreacion: -1 });

    return res.json(calificaciones);
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al listar calificaciones', error: err.message });
  }
}

// POST /api/v1/espacios/:idEspacio/calificaciones
// requiere requireAuth y rol estudiante/admin
async function crearCalificacion(req, res) {
  try {
    const { idEspacio } = req.params;
    const { puntuacion, comentario } = req.body;

    if (!puntuacion || puntuacion < 1 || puntuacion > 5) {
      return res.status(400).json({
        message: 'La puntuación es obligatoria y debe estar entre 1 y 5',
      });
    }

    // Verificar que el espacio exista
    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    // idUsuario viene del token (req.user.sub)
    const idUsuario = req.user?.sub;
    if (!idUsuario) {
      return res
        .status(401)
        .json({ message: 'Usuario no autenticado en el token' });
    }

    // Crear la calificación
    const nueva = await Calificacion.create({
      idEspacio,
      idUsuario,
      puntuacion,
      comentario,
    });

    // Recalcular el promedio de calificación del espacio
    const agg = await Calificacion.aggregate([
      { $match: { idEspacio } },
      {
        $group: {
          _id: '$idEspacio',
          promedio: { $avg: '$puntuacion' },
        },
      },
    ]);

    const nuevoPromedio = agg.length > 0 ? agg[0].promedio : 0;

    await Espacio.updateOne(
      { idEspacio },
      { $set: { promedioCalificacion: nuevoPromedio } }
    );

    return res.status(201).json({
      message: 'Calificación creada',
      calificacion: nueva.toJSON(),
      promedioCalificacion: nuevoPromedio,
    });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al crear calificación', error: err.message });
  }
}

module.exports = {
  listarCalificacionesPorEspacio,
  crearCalificacion,
};

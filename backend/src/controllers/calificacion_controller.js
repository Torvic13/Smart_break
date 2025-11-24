const Calificacion = require('../models/calificacion_model');
const Espacio = require('../models/espacio_model');

// GET /api/v1/espacios/:idEspacio/calificaciones
async function listarCalificacionesPorEspacio(req, res) {
  try {
    const { idEspacio } = req.params;

    const calificaciones = await Calificacion.aggregate([
      { $match: { idEspacio } },
      { $sort: { fechaCreacion: -1 } },
      {
        $lookup: {
          from: 'usuarios',
          localField: 'idUsuario',
          foreignField: 'idUsuario',
          as: 'usuario',
        },
      },
      { $unwind: { path: '$usuario', preserveNullAndEmptyArrays: true } },
      {
        $lookup: {
          from: 'espacios',
          localField: 'idEspacio',
          foreignField: 'idEspacio',
          as: 'espacio',
        },
      },
      { $unwind: { path: '$espacio', preserveNullAndEmptyArrays: true } },
      {
        $project: {
          _id: 0,
          idCalificacion: 1,
          idEspacio: 1,
          idUsuario: 1,
          puntuacion: 1,
          comentario: 1,
          fechaCreacion: 1,
          estado: 1,
          codigoAlumno: '$usuario.codigoAlumno',
          nombreCompleto: '$usuario.nombreCompleto',
          email: '$usuario.email',
          nombreEspacio: '$espacio.nombre', // 👈 nuevo
        },
      },
    ]);

    return res.json(calificaciones);
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al listar calificaciones por espacio', error: err.message });
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

async function recalcularPromedio(idEspacio) {
  const agg = await Calificacion.aggregate([
    { $match: { idEspacio } },
    { $group: { _id: '$idEspacio', promedio: { $avg: '$puntuacion' } } },
  ]);

  const nuevoPromedio = agg.length > 0 ? agg[0].promedio : 0;

  await Espacio.updateOne(
    { idEspacio },
    { $set: { promedioCalificacion: nuevoPromedio } }
  );

  return nuevoPromedio;
}

// PUT /api/v1/calificaciones/:idCalificacion
async function actualizarCalificacion(req, res) {
  try {
    const { idCalificacion } = req.params;
    const { puntuacion, comentario } = req.body;

    const calif = await Calificacion.findOne({ idCalificacion });
    if (!calif) {
      return res.status(404).json({ message: 'Calificación no encontrada' });
    }

    // Solo el dueño o admin pueden editar
    if (req.user.rol !== 'admin' && calif.idUsuario !== req.user.sub) {
      return res.status(403).json({ message: 'No autorizado para editar' });
    }

    if (puntuacion != null) {
      if (puntuacion < 1 || puntuacion > 5) {
        return res.status(400).json({
          message: 'La puntuación debe estar entre 1 y 5',
        });
      }
      calif.puntuacion = puntuacion;
    }

    if (comentario != null) {
      calif.comentario = comentario;
    }

    await calif.save();
    const nuevoPromedio = await recalcularPromedio(calif.idEspacio);

    return res.json({
      message: 'Calificación actualizada',
      calificacion: calif.toJSON(),
      promedioCalificacion: nuevoPromedio,
    });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al actualizar calificación', error: err.message });
  }
}

// DELETE /api/v1/calificaciones/:idCalificacion
async function eliminarCalificacion(req, res) {
  try {
    const { idCalificacion } = req.params;

    const calif = await Calificacion.findOne({ idCalificacion });
    if (!calif) {
      return res.status(404).json({ message: 'Calificación no encontrada' });
    }

    // Solo dueño o admin
    if (req.user.rol !== 'admin' && calif.idUsuario !== req.user.sub) {
      return res.status(403).json({ message: 'No autorizado para eliminar' });
    }

    const idEspacio = calif.idEspacio;

    await Calificacion.deleteOne({ idCalificacion });

    const nuevoPromedio = await recalcularPromedio(idEspacio);

    return res.json({
      message: 'Calificación eliminada',
      promedioCalificacion: nuevoPromedio,
    });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al eliminar calificación', error: err.message });
  }
}
// Listar todas las calificaciones (solo admin)
async function listarTodasCalificaciones(_req, res) {
  try {
    const calificaciones = await Calificacion.aggregate([
      { $sort: { fechaCreacion: -1 } },
      // 👇 Join con usuarios
      {
        $lookup: {
          from: 'usuarios',
          localField: 'idUsuario',
          foreignField: 'idUsuario',
          as: 'usuario',
        },
      },
      { $unwind: { path: '$usuario', preserveNullAndEmptyArrays: true } },
      // 👇 Join con espacios
      {
        $lookup: {
          from: 'espacios',
          localField: 'idEspacio',
          foreignField: 'idEspacio',
          as: 'espacio',
        },
      },
      { $unwind: { path: '$espacio', preserveNullAndEmptyArrays: true } },
      {
        $project: {
          _id: 0,
          idCalificacion: 1,
          idEspacio: 1,
          idUsuario: 1,
          puntuacion: 1,
          comentario: 1,
          fechaCreacion: 1,
          estado: 1,
          codigoAlumno: '$usuario.codigoAlumno',
          nombreCompleto: '$usuario.nombreCompleto',
          email: '$usuario.email',
          // 👇 nuevo campo
          nombreEspacio: '$espacio.nombre',
        },
      },
    ]);

    return res.json(calificaciones);
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ message: 'Error al listar calificaciones', error: err.message });
  }
}


module.exports = {
  listarTodasCalificaciones,
  listarCalificacionesPorEspacio,
  crearCalificacion,
  actualizarCalificacion,
  eliminarCalificacion,
};

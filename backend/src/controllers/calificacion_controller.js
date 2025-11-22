const Calificacion = require('../models/calificacion_model');
const Espacio = require('../models/espacio_model');

// GET /api/v1/calificaciones/usuarios/:idUsuario
async function obtenerCalificacionesPorUsuario(req, res) {
  try {
    const { idUsuario } = req.params;
    
    const calificaciones = await Calificacion.find({ 
      idUsuario, 
      estado: 'activo' 
    }).sort({ fecha: -1 });

    return res.json(calificaciones);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ 
      message: 'Error al obtener calificaciones del usuario', 
      error: err.message 
    });
  }
}

// GET /api/v1/calificaciones/espacios/:idEspacio
async function obtenerCalificacionesPorEspacio(req, res) {
  try {
    const { idEspacio } = req.params;
    
    const calificaciones = await Calificacion.find({ 
      idEspacio, 
      estado: 'activo' 
    }).sort({ fecha: -1 });

    return res.json(calificaciones);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ 
      message: 'Error al obtener calificaciones del espacio', 
      error: err.message 
    });
  }
}

// POST /api/v1/calificaciones
async function crearCalificacion(req, res) {
  try {
    const { puntuacion, comentario, idEspacio } = req.body;
    const idUsuario = req.user.sub; // Del token JWT

    if (!puntuacion || !idEspacio) {
      return res.status(400).json({ 
        message: 'puntuacion y idEspacio son obligatorios' 
      });
    }

    // Verificar que el espacio existe
    const espacio = await Espacio.findOne({ idEspacio });
    if (!espacio) {
      return res.status(404).json({ message: 'Espacio no encontrado' });
    }

    // Verificar si ya existe una calificación del usuario para este espacio
    const calificacionExistente = await Calificacion.findOne({
      idUsuario,
      idEspacio,
      estado: 'activo'
    });

    let calificacion;

    if (calificacionExistente) {
      // Actualizar calificación existente
      calificacionExistente.puntuacion = puntuacion;
      calificacionExistente.comentario = comentario || '';
      calificacionExistente.fecha = new Date();
      
      calificacion = await calificacionExistente.save();
    } else {
      // Crear nueva calificación
      calificacion = await Calificacion.create({
        puntuacion,
        comentario: comentario || '',
        idUsuario,
        idEspacio,
      });
    }

    // Actualizar el promedio de calificaciones del espacio
    await actualizarPromedioCalificaciones(idEspacio);

    return res.status(201).json({ 
      message: calificacionExistente ? 'Calificación actualizada' : 'Calificación creada',
      calificacion: calificacion.toJSON() 
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ 
      message: 'Error al crear/actualizar calificación', 
      error: err.message 
    });
  }
}

// PUT /api/v1/calificaciones/:idCalificacion
async function actualizarCalificacion(req, res) {
  try {
    const { idCalificacion } = req.params;
    const { puntuacion, comentario } = req.body;
    const idUsuario = req.user.sub; // Del token JWT

    const calificacion = await Calificacion.findOne({ 
      idCalificacion, 
      idUsuario,
      estado: 'activo' 
    });

    if (!calificacion) {
      return res.status(404).json({ message: 'Calificación no encontrada' });
    }

    // Actualizar campos
    if (puntuacion !== undefined) calificacion.puntuacion = puntuacion;
    if (comentario !== undefined) calificacion.comentario = comentario;
    calificacion.fecha = new Date();

    const calificacionActualizada = await calificacion.save();

    // Actualizar promedio del espacio
    await actualizarPromedioCalificaciones(calificacion.idEspacio);

    return res.json({ 
      message: 'Calificación actualizada',
      calificacion: calificacionActualizada.toJSON() 
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ 
      message: 'Error al actualizar calificación', 
      error: err.message 
    });
  }
}

// DELETE /api/v1/calificaciones/:idCalificacion
async function eliminarCalificacion(req, res) {
  try {
    const { idCalificacion } = req.params;
    const idUsuario = req.user.sub; // Del token JWT

    const calificacion = await Calificacion.findOne({ 
      idCalificacion, 
      idUsuario 
    });

    if (!calificacion) {
      return res.status(404).json({ message: 'Calificación no encontrada' });
    }

    // Soft delete (cambiar estado a inactivo)
    calificacion.estado = 'inactivo';
    await calificacion.save();

    // Actualizar promedio del espacio
    await actualizarPromedioCalificaciones(calificacion.idEspacio);

    return res.json({ message: 'Calificación eliminada' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ 
      message: 'Error al eliminar calificación', 
      error: err.message 
    });
  }
}

// Función auxiliar para actualizar promedio de calificaciones
async function actualizarPromedioCalificaciones(idEspacio) {
  try {
    const calificacionesActivas = await Calificacion.find({ 
      idEspacio, 
      estado: 'activo' 
    });

    if (calificacionesActivas.length === 0) {
      // Si no hay calificaciones, poner promedio en 0
      await Espacio.findOneAndUpdate(
        { idEspacio },
        { promedioCalificacion: 0 }
      );
      return;
    }

    const sumaPuntuaciones = calificacionesActivas.reduce(
      (sum, calif) => sum + calif.puntuacion, 
      0
    );
    const promedio = sumaPuntuaciones / calificacionesActivas.length;

    await Espacio.findOneAndUpdate(
      { idEspacio },
      { promedioCalificacion: Math.round(promedio * 10) / 10 } // Redondear a 1 decimal
    );
  } catch (err) {
    console.error('Error al actualizar promedio:', err);
  }
}

module.exports = {
  obtenerCalificacionesPorUsuario,
  obtenerCalificacionesPorEspacio,
  crearCalificacion,
  actualizarCalificacion,
  eliminarCalificacion,
};
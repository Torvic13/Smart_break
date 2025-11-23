const mongoose = require('mongoose');
const { randomUUID } = require('crypto');

const calificacionSchema = new mongoose.Schema(
  {
    idCalificacion: {
      type: String,
      unique: true,
      required: true,
      index: true,
    },
    idEspacio: {
      type: String,
      required: true,
      index: true,
    },
    idUsuario: {
      type: String,
      required: true,
      index: true,
    },
    puntuacion: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comentario: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    fechaCreacion: {
      type: Date,
      default: Date.now,
    },
  },
  { versionKey: false }
);

// Generar idCalificacion si no viene
calificacionSchema.pre('validate', function (next) {
  if (!this.idCalificacion) this.idCalificacion = randomUUID();
  next();
});

// Formato JSON amigable para el front
calificacionSchema.set('toJSON', {
  transform: (_doc, ret) => {
    if (ret.fechaCreacion instanceof Date) {
      ret.fechaCreacion = ret.fechaCreacion.toISOString();
    }
    delete ret._id;
    return ret;
  },
});

module.exports = mongoose.model('Calificacion', calificacionSchema, 'calificaciones');

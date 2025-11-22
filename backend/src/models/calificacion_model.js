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
    puntuacion: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comentario: {
      type: String,
      default: '',
      trim: true,
    },
    fecha: {
      type: Date,
      default: Date.now,
    },
    estado: {
      type: String,
      enum: ['activo', 'inactivo'],
      default: 'activo',
    },
    idUsuario: {
      type: String,
      required: true,
      index: true,
    },
    idEspacio: {
      type: String,
      required: true,
      index: true,
    },
  },
  { versionKey: false }
);

// Generar idCalificacion si no viene
calificacionSchema.pre('validate', function (next) {
  if (!this.idCalificacion) this.idCalificacion = randomUUID();
  next();
});

// Formato JSON
calificacionSchema.set('toJSON', {
  transform: (_doc, ret) => {
    if (ret.fecha instanceof Date) {
      ret.fecha = ret.fecha.toISOString();
    }
    delete ret._id;
    return ret;
  },
});

module.exports = mongoose.model('Calificacion', calificacionSchema, 'calificaciones');
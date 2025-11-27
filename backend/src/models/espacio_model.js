// src/models/espacio_model.js
const mongoose = require('mongoose');
const { randomUUID } = require('crypto');

// --- Subdocumento Ubicación ---
const ubicacionSchema = new mongoose.Schema(
  {
    latitud: { type: Number, required: true },
    longitud: { type: Number, required: true },
    piso: { type: String },
    edificio: { type: String },
  },
  { _id: false }
);

// --- Subdocumento Característica ---
const caracteristicaSchema = new mongoose.Schema(
  {
    idCaracteristica: { type: String, required: true },
    nombre: { type: String, required: true },
    valor: { type: String, required: true },
    tipoFiltro: { type: String, required: true },
  },
  { _id: false }
);

const NIVEL_OCUPACION = ['vacio', 'bajo', 'medio', 'alto', 'lleno'];

const espacioSchema = new mongoose.Schema(
  {
    idEspacio: {
      type: String,
      unique: true,
      required: true,
      index: true,
    },
    nombre: {
      type: String,
      required: true,
      trim: true,
    },
    tipo: {
      type: String,
      required: true,
      trim: true, // "Biblioteca", "Cafetería", etc.
    },

    // 🔹 Nivel ocupación semáforo
    nivelOcupacion: {
      type: String,
      enum: NIVEL_OCUPACION,
      default: 'vacio',
    },

    // 🔹 NUEVOS CAMPOS DE AFORO
    aforoMaximo: {
      type: Number,
      default: 50,   // valor por defecto para espacios antiguos
      min: 1,
    },
    ocupacionActual: {
      type: Number,
      default: 0,
      min: 0,
    },

    promedioCalificacion: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    ubicacion: {
      type: ubicacionSchema,
      required: true,
    },
    caracteristicas: {
      type: [caracteristicaSchema],
      default: [],
    },
    categoriaIds: {
      type: [String],
      default: [],
    },
  },
  { versionKey: false }
);

// Generar idEspacio si no viene
espacioSchema.pre('validate', function (next) {
  if (!this.idEspacio) this.idEspacio = randomUUID();

  // 🔹 Asegurar valores por defecto también en docs antiguos
  if (!this.aforoMaximo || this.aforoMaximo <= 0) {
    this.aforoMaximo = 50;
  }
  if (this.ocupacionActual == null || this.ocupacionActual < 0) {
    this.ocupacionActual = 0;
  }

  next();
});

// Formato JSON que encaja bien con tu front
espacioSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete ret._id;
    return ret;
  },
});

module.exports = mongoose.model('Espacio', espacioSchema, 'espacios');
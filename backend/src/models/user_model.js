const mongoose = require('mongoose');
const { randomUUID } = require('crypto');

const ESTADOS = ['activo', 'inactivo', 'suspendido'];
const ROLES   = ['admin', 'estudiante'];

const userSchema = new mongoose.Schema(
  {
    idUsuario: {
      type: String,
      unique: true,
      index: true,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      match: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,
    },
    fechaCreacion: {
      type: Date,
      default: Date.now,
    },
    estado: {
      type: String,
      enum: ESTADOS,
      default: 'activo',
    },
    rol: {
      type: String,
      enum: ROLES,
      default: 'estudiante',
      required: true,
    },

    // ---- Campos extra solo para rol=estudiante (planos, como en tu front) ----
    codigoAlumno: {
      type: String,
      required: function () { return this.rol === 'estudiante'; },
    },
    nombreCompleto: {
      type: String,
      required: function () { return this.rol === 'estudiante'; },
      trim: true,
    },
    ubicacionCompartida: {
      type: Boolean,
      default: false,
    },
    carrera: {
      type: String,
      default: function () { return this.rol === 'estudiante' ? 'No especificada' : undefined; },
      trim: true,
    },

    // ==================================================================
    // NUEVOS CAMPOS PARA HU22 – CONTROL DE ABUSO EN REPORTES
    // ==================================================================
    ultimoReportePorEspacio: {
      type: Map,
      of: Date,
      default: () => new Map() // espacioId → Date del último reporte
    },
    reportesHoy: {
      type: Number,
      default: 0,
      min: 0
    },
    ultimoResetDiario: {
      type: Date,
      default: Date.now
    }
    // ==================================================================
  },
  { versionKey: false }
);

// Generar idUsuario si no existe
userSchema.pre('validate', function (next) {
  if (!this.idUsuario) this.idUsuario = randomUUID();
  next();
});

// Formatear salida JSON
userSchema.set('toJSON', {
  transform: (_doc, ret) => {
    if (ret.fechaCreacion instanceof Date) {
      ret.fechaCreacion = ret.fechaCreacion.toISOString();
    }
    delete ret._id;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema, 'usuarios');
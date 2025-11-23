// src/models/incidencia_model.js
const mongoose = require('mongoose');
const { randomUUID } = require('crypto');

const TIPOS_INCIDENCIA = [
  'Daño en infraestructura',
  'Falta de limpieza',
  'Ruido excesivo',
  'Problemas de temperatura',
  'Falta de servicios (WiFi, enchufes)',
  'Seguridad',
  'Otro',
];

const incidenciaSchema = new mongoose.Schema(
  {
    idIncidencia: {
      type: String,
      unique: true,
      index: true,
      required: true,
      default: () => randomUUID(),
    },
    idEspacio: {
      type: String,
      required: true,
      index: true,
    },
    nombreEspacio: {
      type: String,
      required: true,
    },
    tipoIncidencia: {
      type: String,
      enum: TIPOS_INCIDENCIA,
      required: true,
    },
    descripcion: {
      type: String,
      required: true,
      maxlength: 500,
    },
    usuarioReporte: {
      type: String,
      required: true, // idUsuario del que reporta
    },
    fechaReporte: {
      type: Date,
      default: Date.now,
    },
    resuelta: {
      type: Boolean,
      default: false,
    },
    fechaResolucion: {
      type: Date,
      default: null,
    },
    notas: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

// Índices compuestos
incidenciaSchema.index({ idEspacio: 1, resuelta: 1 });
incidenciaSchema.index({ usuarioReporte: 1, fechaReporte: -1 });

const Incidencia = mongoose.model('Incidencia', incidenciaSchema);

module.exports = Incidencia;

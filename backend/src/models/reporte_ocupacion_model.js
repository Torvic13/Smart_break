// src/models/reporte_ocupacion_model.js
const mongoose = require('mongoose');

const reporteOcupacionSchema = new mongoose.Schema({
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  espacioId: {
    type: String,
    required: true
  },
  nivelOcupacion: {
    type: String,
    enum: ['vacio', 'bajo', 'medio', 'alto', 'lleno'],
    required: true
  },
  fecha: {
    type: Date,
    default: Date.now
  }
}, { versionKey: false });

module.exports = mongoose.model('ReporteOcupacion', reporteOcupacionSchema, 'reportes_ocupacion');
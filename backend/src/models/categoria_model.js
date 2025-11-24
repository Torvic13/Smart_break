// src/models/categoria_model.js
const mongoose = require('mongoose');
const { randomUUID } = require('crypto');

const categoriaSchema = new mongoose.Schema(
  {
    idCategoria: {
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
      enum: ['tipoEspacio', 'nivelRuido', 'comodidad', 'capacidad', 'bloqueHorario'],
      trim: true,
    },
    descripcion: {
      type: String,
      trim: true,
      default: '',
    },
    icono: {
      type: String,
      default: 'category',
    },
    activa: {
      type: Boolean,
      default: true,
    },
  },
  { versionKey: false, timestamps: true }
);

// Generar idCategoria si no viene
categoriaSchema.pre('validate', function (next) {
  if (!this.idCategoria) this.idCategoria = randomUUID();
  next();
});

// Formato JSON
categoriaSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete ret._id;
    return ret;
  },
});

module.exports = mongoose.model('Categoria', categoriaSchema, 'categorias');

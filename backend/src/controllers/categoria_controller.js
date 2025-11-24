// src/controllers/categoria_controller.js
const Categoria = require('../models/categoria_model');

// GET /api/v1/categorias (con filtro opcional por tipo)
async function listarCategorias(req, res) {
  try {
    const { tipo } = req.query;
    const filtro = { activa: true };
    
    if (tipo) {
      filtro.tipo = tipo;
    }
    
    const categorias = await Categoria.find(filtro).sort({ nombre: 1 });
    return res.json(categorias);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al listar categorías', error: err.message });
  }
}

// GET /api/v1/categorias/:idCategoria
async function obtenerCategoria(req, res) {
  try {
    const { idCategoria } = req.params;
    const categoria = await Categoria.findOne({ idCategoria });
    
    if (!categoria) {
      return res.status(404).json({ message: 'Categoría no encontrada' });
    }
    
    return res.json(categoria);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al obtener categoría', error: err.message });
  }
}

// POST /api/v1/categorias (solo admin)
async function crearCategoria(req, res) {
  try {
    const { nombre, tipo, descripcion, icono, activa = true } = req.body;

    if (!nombre) {
      return res.status(400).json({ message: 'nombre es obligatorio' });
    }

    if (!tipo) {
      return res.status(400).json({ message: 'tipo es obligatorio' });
    }

    const existe = await Categoria.findOne({ nombre, tipo });
    if (existe) {
      return res.status(400).json({ message: 'Ya existe una categoría con ese nombre en ese tipo' });
    }

    const nueva = await Categoria.create({
      nombre,
      tipo,
      descripcion,
      icono,
      activa,
    });

    return res.status(201).json({ message: 'Categoría creada', categoria: nueva.toJSON() });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al crear categoría', error: err.message });
  }
}

// PUT /api/v1/categorias/:idCategoria (solo admin)
async function actualizarCategoria(req, res) {
  try {
    const { idCategoria } = req.params;
    const { nombre, descripcion, icono, activa } = req.body;

    const updates = {};
    if (nombre !== undefined) updates.nombre = nombre;
    if (descripcion !== undefined) updates.descripcion = descripcion;
    if (icono !== undefined) updates.icono = icono;
    if (activa !== undefined) updates.activa = activa;

    const categoria = await Categoria.findOneAndUpdate(
      { idCategoria },
      updates,
      { new: true, runValidators: false }
    );

    if (!categoria) {
      return res.status(404).json({ message: 'Categoría no encontrada' });
    }

    return res.json({ message: 'Categoría actualizada', categoria: categoria.toJSON() });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al actualizar categoría', error: err.message });
  }
}

// DELETE /api/v1/categorias/:idCategoria (solo admin)
async function eliminarCategoria(req, res) {
  try {
    const { idCategoria } = req.params;

    const categoria = await Categoria.findOneAndUpdate(
      { idCategoria },
      { activa: false },
      { new: true }
    );

    if (!categoria) {
      return res.status(404).json({ message: 'Categoría no encontrada' });
    }

    return res.json({ message: 'Categoría eliminada (desactivada)' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al eliminar categoría', error: err.message });
  }
}

module.exports = {
  listarCategorias,
  obtenerCategoria,
  crearCategoria,
  actualizarCategoria,
  eliminarCategoria,
};

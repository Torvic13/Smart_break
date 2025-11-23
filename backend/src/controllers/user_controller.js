const bcrypt = require('bcryptjs');
const User = require('../models/user_model');

// POST /api/v1/usuarios
async function crearUsuario(req, res) {
  try {
    const { email, password, rol = 'estudiante', estado = 'activo' } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'email y password son obligatorios' });
    }

    const existe = await User.findOne({ email });
    if (existe) return res.status(400).json({ message: 'El correo ya está registrado' });

    const passwordHash = await bcrypt.hash(password, 10);

    // Datos comunes
    const base = { email, passwordHash, rol, estado };

    // Si es estudiante, exigir y mapear extras
    if (rol === 'estudiante') {
      const {
        codigoAlumno,
        nombreCompleto,
        ubicacionCompartida = false,
        carrera = 'No especificada',
      } = req.body;

      if (!codigoAlumno || !nombreCompleto) {
        return res.status(400).json({
          message: 'Faltan campos de estudiante: codigoAlumno y nombreCompleto',
        });
      }

      Object.assign(base, {
        codigoAlumno,
        nombreCompleto,
        ubicacionCompartida,
        carrera,
      });
    }

    const nuevo = await User.create(base);
    const json = nuevo.toJSON();
    delete json.passwordHash;

    return res.status(201).json({ message: 'Usuario creado', usuario: json });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al crear usuario', error: err.message });
  }
}

// GET /api/v1/usuarios
async function listarUsuarios(_req, res) {
  try {
    const usuarios = await User.find().select('-passwordHash');
    return res.json(usuarios);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al listar usuarios', error: err.message });
  }
}

// GET /api/v1/usuarios/buscar/:codigoAlumno
async function buscarPorCodigo(req, res) {
  try {
    const { codigoAlumno } = req.params;
    const usuario = await User.findOne({ codigoAlumno, rol: 'estudiante' }).select('-passwordHash');
    
    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    
    return res.json({ usuario: usuario.toJSON() });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al buscar usuario', error: err.message });
  }
}

// POST /api/v1/usuarios/:idUsuario/amigos
async function agregarAmigo(req, res) {
  try {
    const { idUsuario } = req.params;
    const { amigoId } = req.body;

    if (!amigoId) {
      return res.status(400).json({ message: 'amigoId es obligatorio' });
    }

    // Verificar que ambos usuarios existen
    const usuario = await User.findOne({ idUsuario });
    const amigo = await User.findOne({ idUsuario: amigoId });

    if (!usuario || !amigo) {
      return res.status(404).json({ message: 'Usuario o amigo no encontrado' });
    }

    // Verificar si ya son amigos
    if (usuario.amigosIds.includes(amigoId)) {
      return res.status(400).json({ message: 'Ya son amigos' });
    }

    // Agregar amigo bilateralmente
    usuario.amigosIds.push(amigoId);
    amigo.amigosIds.push(idUsuario);

    await usuario.save();
    await amigo.save();

    return res.json({ message: 'Amigo agregado exitosamente' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al agregar amigo', error: err.message });
  }
}

// GET /api/v1/usuarios/:idUsuario/amigos
async function obtenerAmigos(req, res) {
  try {
    const { idUsuario } = req.params;
    
    const usuario = await User.findOne({ idUsuario });
    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    // Obtener información de los amigos
    const amigos = await User.find({ 
      idUsuario: { $in: usuario.amigosIds } 
    }).select('-passwordHash');

    return res.json({ amigos });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Error al obtener amigos', error: err.message });
  }
}

module.exports = { crearUsuario, listarUsuarios, buscarPorCodigo, agregarAmigo, obtenerAmigos };
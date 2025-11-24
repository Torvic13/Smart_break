// routes/auth_routes.js

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Usuario = require('../models/user_model'); // ← Correcto

// ===============================================
// 1. LOGIN (CORREGIDO: .select('+passwordHash'))
// ===============================================
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Faltan credenciales' });
    }

    // ← LA LÍNEA CLAVE: traer passwordHash aunque tenga select: false
    const usuario = await Usuario.findOne({ email }).select('+passwordHash');

    if (!usuario) {
      return res.status(400).json({ message: 'Credenciales incorrectas' });
    }

    const passwordValido = await bcrypt.compare(password, usuario.passwordHash);
    if (!passwordValido) {
      return res.status(400).json({ message: 'Credenciales incorrectas' });
    }

    const token = jwt.sign(
      { id: usuario._id, rol: usuario.rol },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES || '2h' }
    );

    res.json({
      success: true,
      token,
      user: {
        id: usuario._id.toString(),
        email: usuario.email,
        nombreCompleto: usuario.nombreCompleto || 'Usuario',
        rol: usuario.rol,
        codigoAlumno: usuario.codigoAlumno || null,
      },
    });
  } catch (error) {
    console.error('Error login:', error);
    res.status(500).json({ message: 'Error del servidor' });
  }
});

// ===============================================
// 2. REGISTRO (CORREGIDO: variable "existe")
// ===============================================
router.post('/register', async (req, res) => {
  try {
    const { email, password, nombreCompleto, codigoAlumno, rol = 'estudiante' } = req.body;

    // ← CORREGIDO: antes decía "existe" pero la variable se llamaba "usuario"
    const existe = await Usuario.findOne({ email });
    if (existe) {
      return res.status(400).json({ message: 'El correo ya existe' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const nuevoUsuario = new Usuario({
      email,
      passwordHash,
      nombreCompleto: nombreCompleto || 'Estudiante',
      codigoAlumno,
      rol,
      estado: 'activo',
    });

    await nuevoUsuario.save();

    res.status(201).json({ success: true, message: 'Usuario creado correctamente' });
  } catch (error) {
    console.error('Error register:', error);
    res.status(500).json({ message: error.message });
  }
});

// ===============================================
// 3. CREAR USUARIO DE PRUEBA
// ===============================================
router.get('/crear-prueba', async (req, res) => {
  try {
    const email = '20251234@aloe.ulima.edu.pe';
    const existe = await Usuario.findOne({ email });

    if (existe) {
      return res.json({ message: 'El usuario de prueba ya existe', email });
    }

    const passwordHash = await bcrypt.hash('123456', 10);

    const usuarioPrueba = new Usuario({
      email,
      passwordHash,
      nombreCompleto: 'Juan Pérez',
      codigoAlumno: '20251234',
      carrera: 'Ingeniería de Sistemas',
      rol: 'estudiante',
      estado: 'activo',
    });

    await usuarioPrueba.save();

    res.json({
      message: '¡Usuario de prueba creado con éxito!',
      email,
      password: '123456',
    });
  } catch (error) {
    console.error('Error crear-prueba:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
// src/utils/create_admin.js
require('dotenv').config({ path: '../../.env' });
const bcrypt = require('bcryptjs');
const connectDB = require('../database');
const Usuario = require('../models/user_model');

async function crearAdmin() {
  try {
    await connectDB();

    const existe = await Usuario.findOne({ email: 'admin@smartbreak.com' });
    if (existe) {
      console.log('⚠️ Ya existe un administrador');
      process.exit(0);
    }

    const passwordHash = await bcrypt.hash('admin123', 10);

    const admin = new Usuario({
      email: 'admin@smartbreak.com',
      passwordHash,
      rol: 'admin',          // ✔ ENUM CORRECTO
      estado: 'activo',      // ✔ ENUM CORRECTO
      // ❗ NO poner codigoAlumno ni nombreCompleto porque solo son requeridos para estudiantes
    });

    await admin.save();

    console.log('✅ Administrador creado con éxito');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creando admin:', error);
    process.exit(1);
  }
}

crearAdmin();

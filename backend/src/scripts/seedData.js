const mongoose = require('mongoose');
const Espacio = require('../models/espacio_model');
const User = require('../models/user_model');
const Calificacion = require('../models/calificacion_model');
require('dotenv').config();

const sampleEspacios = [
  {
    idEspacio: 'espacio-001',
    nombre: 'Sala de Estudio Silenciosa',
    tipo: 'Sala de Estudio',
    nivelOcupacion: 'bajo',
    promedioCalificacion: 4.5,
    ubicacion: {
      latitud: -12.0464,
      longitud: -77.0428,
      piso: '3',
      edificio: 'Biblioteca Central'
    },
    caracteristicas: [
      {
        idCaracteristica: 'car-001',
        nombre: 'Wi-Fi',
        valor: 'Disponible',
        tipoFiltro: 'conectividad'
      },
      {
        idCaracteristica: 'car-002', 
        nombre: 'Enchufes',
        valor: 'Suficientes',
        tipoFiltro: 'comodidad'
      }
    ],
    categoriaIds: ['cat-estudio', 'cat-silencioso']
  },
  {
    idEspacio: 'espacio-002',
    nombre: 'Cafetería Principal',
    tipo: 'Cafetería',
    nivelOcupacion: 'medio',
    promedioCalificacion: 4.2,
    ubicacion: {
      latitud: -12.0450,
      longitud: -77.0430,
      piso: '1', 
      edificio: 'Comedor Principal'
    },
    caracteristicas: [
      {
        idCaracteristica: 'car-003',
        nombre: 'Comida',
        valor: 'Variedad',
        tipoFiltro: 'servicios'
      },
      {
        idCaracteristica: 'car-004',
        nombre: 'Ruido',
        valor: 'Moderado', 
        tipoFiltro: 'ambiente'
      }
    ],
    categoriaIds: ['cat-social', 'cat-comida']
  },
  {
    idEspacio: 'espacio-003',
    nombre: 'Laboratorio de Computación',
    tipo: 'Laboratorio',
    nivelOcupacion: 'alto',
    promedioCalificacion: 4.0,
    ubicacion: {
      latitud: -12.0440,
      longitud: -77.0410,
      piso: '2',
      edificio: 'Edificio de Ingeniería'
    },
    caracteristicas: [
      {
        idCaracteristica: 'car-005',
        nombre: 'Computadoras',
        valor: 'Disponibles',
        tipoFiltro: 'equipamiento'
      },
      {
        idCaracteristica: 'car-006',
        nombre: 'Software',
        valor: 'Especializado',
        tipoFiltro: 'equipamiento'
      }
    ],
    categoriaIds: ['cat-tecnologia', 'cat-estudio']
  }
];

const sampleUsers = [
  {
    idUsuario: 'user-001',
    email: 'estudiante@universidad.edu',
    passwordHash: '$2a$10$dummyhashfortesting123456789012',
    rol: 'estudiante',
    codigoAlumno: '20230001',
    nombreCompleto: 'Juan Pérez García',
    ubicacionCompartida: true,
    carrera: 'Ingeniería de Software'
  }
];

async function seedDatabase() {
  try {
    // Conectar a la base de datos
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Conectado a MongoDB');

    // Limpiar colecciones existentes
    await Espacio.deleteMany({});
    await User.deleteMany({});
    await Calificacion.deleteMany({});
    console.log('✅ Colecciones limpiadas');

    // Insertar datos de prueba
    await Espacio.insertMany(sampleEspacios);
    console.log('✅ Espacios de prueba creados');

    await User.insertMany(sampleUsers);
    console.log('✅ Usuarios de prueba creados');

    // Mostrar resumen
    const espaciosCount = await Espacio.countDocuments();
    const usersCount = await User.countDocuments();
    
    console.log(`\n📊 Resumen de datos:`);
    console.log(`   - Espacios: ${espaciosCount}`);
    console.log(`   - Usuarios: ${usersCount}`);
    console.log('\n🎯 URLs para probar:');
    console.log('   GET /api/v1/espacios/disponibles');
    console.log('   GET /api/v1/calificaciones/usuarios/user-001');
    console.log('   POST /api/v1/calificaciones');

  } catch (error) {
    console.error('❌ Error al sembrar la base de datos:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Conexión cerrada - Datos listos para usar');
  }
}

// Ejecutar el script
seedDatabase();
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');

// Rutas
const espacioRoutes = require('./routes/espacio_routes');
const calificacionRoutes = require('./routes/calificacion_routes');
const userRoutes = require('./routes/user_routes');
const authRoutes = require('./routes/auth_routes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/', (_req, res) =>
  res.json({ message: 'API SmartBreak funcionando 🧠' })
);

// Usuarios
app.use('/api/v1/usuarios', userRoutes);

// Auth
app.use('/api/v1/auth', authRoutes);

// Espacios
app.use('/api/v1/espacios', espacioRoutes);

// Calificaciones
app.use('/api/v1/calificaciones', calificacionRoutes);

module.exports = app;

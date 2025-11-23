const express = require('express');
const morgan  = require('morgan');
const cors    = require('cors');

// Middlewares de autenticación
const { requireAuth, requireRole } = require('./middlewares/auth_middleware');

// 🆕 Importar rutas de espacios
const espacioRoutes = require('./routes/espacio_routes');
const calificacionRoutes = require('./routes/calificacion_routes');
const app = express();

// Middlewares globales
app.use(express.json());
app.use(morgan('dev'));
app.use(cors());
app.use('/api/v1', calificacionRoutes);
// Ruta base de prueba
app.get('/', (_req, res) => res.json({ message: 'API SmartBreak funcionando 🧠' }));

// Rutas de usuario
app.use('/api/v1/usuarios', require('./routes/user_routes'));

// Rutas de autenticación
app.use('/api/v1/auth', require('./routes/auth_routes'));

// 🆕 Registrar rutas de espacios
app.use('/api/v1/espacios', espacioRoutes);

// Ejemplo: ruta protegida
app.get('/api/v1/me', requireAuth, (req, res) => {
  res.json({ ok: true, user: req.user });
});

// Ejemplo: ruta solo admin
app.post('/api/v1/admin/only', requireAuth, requireRole('admin'), (req, res) => {
  res.json({ ok: true, message: 'Acceso de administrador concedido 👑' });
});

module.exports = app;

const express = require('express');
const morgan  = require('morgan');
const cors    = require('cors');

// Middlewares de autenticación
const { requireAuth, requireRole } = require('./middlewares/auth_middleware');

// Importar rutas
const espacioRoutes = require('./routes/espacio_routes');
const categoriaRoutes = require('./routes/categoria_routes');

const app = express();

// Middlewares globales
app.use(express.json());
app.use(morgan('dev'));
app.use(cors());

// Ruta base de prueba
app.get('/', (_req, res) => res.json({ message: 'API SmartBreak funcionando' }));

// Rutas de usuario
app.use('/api/v1/usuarios', require('./routes/user_routes'));

// Rutas de autenticación
app.use('/api/v1/auth', require('./routes/auth_routes'));

// Registrar rutas de espacios y categorías
app.use('/api/v1/espacios', espacioRoutes);
app.use('/api/v1/categorias', categoriaRoutes);

// Ejemplo: ruta protegida
app.get('/api/v1/me', requireAuth, (req, res) => {
  res.json({ ok: true, user: req.user });
});

// Ejemplo: ruta solo admin
app.post('/api/v1/admin/only', requireAuth, requireRole('admin'), (req, res) => {
  res.json({ ok: true, message: 'Acceso de administrador concedido' });
});

module.exports = app;

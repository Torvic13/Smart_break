const express = require('express');
const morgan  = require('morgan');
const cors    = require('cors');

// ✅ Importa middlewares para autenticación
const { requireAuth, requireRole } = require('./middlewares/auth_middleware');

const app = express();

app.use(express.json());
app.use(morgan('dev'));
app.use(cors());

// 🌐 Ruta base (ping de prueba)
app.get('/', (_req, res) => res.json({ message: 'API SmartBreak funcionando 🧠' }));

// 👤 Rutas de usuario
app.use('/api/v1/usuarios', require('./routes/user_routes'));

// 🔐 Rutas de autenticación (login)
app.use('/api/v1/auth', require('./routes/auth_routes'));

// 🧩 Ejemplo: ruta protegida (necesita token válido)
app.get('/api/v1/me', requireAuth, (req, res) => {
  res.json({ ok: true, user: req.user }); // req.user viene del token
});

// 🛡️ Ejemplo: solo accesible por administradores
app.post('/api/v1/admin/only', requireAuth, requireRole('admin'), (req, res) => {
  res.json({ ok: true, message: 'Acceso de administrador concedido 👑' });
});

module.exports = app;
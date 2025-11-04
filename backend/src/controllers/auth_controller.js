const bcrypt = require('bcryptjs');
const User = require('../models/user_model');
const { signJwt } = require('../utils/jwt');

// POST /api/v1/auth/login
async function login(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: 'email y password son obligatorios' });

    // Traer hash (en el modelo tiene select:false)
    const user = await User.findOne({ email }).select('+passwordHash');
    if (!user) return res.status(401).json({ message: 'Credenciales inválidas' });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ message: 'Credenciales inválidas' });

    if (user.estado === 'suspendido')
      return res.status(403).json({ message: 'Usuario suspendido' });

    const payload = { sub: user.idUsuario, email: user.email, rol: user.rol };
    const accessToken = signJwt(payload);

    const data = user.toJSON();
    delete data.passwordHash;

    return res.json({ accessToken, usuario: data });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error en login', error: err.message });
  }
}

module.exports = { login };
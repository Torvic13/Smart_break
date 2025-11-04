const { verifyJwt } = require('../utils/jwt');

function requireAuth(req, res, next) {
  const auth = req.headers.authorization || '';
  const [, token] = auth.split(' '); // "Bearer <token>"
  if (!token) return res.status(401).json({ message: 'Token requerido' });

  try {
    req.user = verifyJwt(token); // { sub, email, rol, iat, exp }
    next();
  } catch {
    res.status(401).json({ message: 'Token inválido o expirado' });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ message: 'No autenticado' });
    if (!roles.includes(req.user.rol)) return res.status(403).json({ message: 'No autorizado' });
    next();
  };
}

module.exports = { requireAuth, requireRole };
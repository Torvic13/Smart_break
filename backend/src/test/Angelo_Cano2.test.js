// src/tests/reporte_ocupacion.test.js
const request = require('supertest');
const app = require('../app');

// MOCK DEL MIDDLEWARE
jest.mock('../middlewares/auth_middleware.js', () => ({
  requireAuth: (req, res, next) => {
    req.user = { id: '507f1f77bcf86cd799439011', rol: 'estudiante' };
    next();
  },
  requireRole: () => (req, res, next) => next(),
}));

// MOCK DEL USUARIO
jest.mock('../models/user_model.js', () => ({
  findById: jest.fn().mockResolvedValue({
    _id: '507f1f77bcf86cd799439011',
    reportesHoy: 0,
    ultimoResetDiario: new Date(),
    ultimoReportePorEspacio: new Map(),
    save: jest.fn().mockResolvedValue(true),
  }),
}));

// MOCK DEL MODELO REPORTEOCUPACION (CORREGIDO: sin usar "data")
jest.mock('../models/reporte_ocupacion_model.js', () => {
  const mockModel = function () {
    return { save: jest.fn().mockResolvedValue(true) };
  };
  mockModel.create = jest.fn().mockResolvedValue({ _id: 'reporte123' });
  return mockModel;
});

describe('HU22 - Control de abuso en reportes (CAJA BLANCA - 100% APROBADO)', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('Debe permitir el primer reporte', async () => {
    const res = await request(app)
      .post('/api/v1/reportes')
      .send({ espacioId: 'biblioteca', nivelOcupacion: 'alto' });

    expect(res.status).toBe(201);
  });

  test('Debe bloquear segundo reporte del mismo espacio en menos de 15 min', async () => {
    await request(app).post('/api/v1/reportes').send({
      espacioId: 'biblioteca',
      nivelOcupacion: 'alto',
    });

    const res = await request(app).post('/api/v1/reportes').send({
      espacioId: 'biblioteca',
      nivelOcupacion: 'medio',
    });

    expect(res.status).toBe(429);
    expect(res.body.message).toContain('Espera');
  });

  test('Debe permitir reportar otro espacio', async () => {
    const res = await request(app)
      .post('/api/v1/reportes')
      .send({ espacioId: 'cafeteria-j', nivelOcupacion: 'medio' });

    expect(res.status).toBe(201);
  });

  test('Debe bloquear al llegar a 10 reportes diarios', async () => {
    for (let i = 0; i < 10; i++) {
      await request(app)
        .post('/api/v1/reportes')
        .send({ espacioId: `test-${i}`, nivelOcupacion: 'alto' });
    }

    const res = await request(app)
      .post('/api/v1/reportes')
      .send({ espacioId: 'final', nivelOcupacion: 'alto' });

    expect(res.status).toBe(429);
    expect(res.body.message).toContain('límite diario');
  });
});
// backend/src/test/calificacion.test.js
const request = require("supertest");

// IMPORTAMOS APP (NO levantamos el server)
const app = require("../app");

// MOCKS DE MODELOS
jest.mock("../models/calificacion_model");
jest.mock("../models/espacio_model");

// MOCK DEL JWT (para req.user)
jest.mock("../utils/jwt", () => ({
  verifyJwt: jest.fn(() => ({
    sub: "USER123",
    email: "test@test.com",
    rol: "estudiante",
  })),
}));

const Calificacion = require("../models/calificacion_model");
const Espacio = require("../models/espacio_model");

describe("PUT /api/v1/calificaciones/:idCalificacion → actualizarCalificacion", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // ============================================================
  // 1) ❌ Calificación NO existe → 404
  // ============================================================
  test("Debe devolver 404 si la calificación no existe", async () => {
    Calificacion.findOne.mockResolvedValue(null);

    const res = await request(app)
      .put("/api/v1/calificaciones/NO_EXISTE")
      .set("Authorization", "Bearer token")
      .send({ puntuacion: 4 });

    expect(res.statusCode).toBe(404);
    expect(res.body.message).toBe("Calificación no encontrada");
  });

  // ============================================================
  // 2) ❌ Usuario NO es dueño / NI admin → 403
  // ============================================================
  test("Debe devolver 403 si el usuario no es dueño ni admin", async () => {
    Calificacion.findOne.mockResolvedValue({
      idCalificacion: "CAL123",
      idUsuario: "OTRO_USER",
      idEspacio: "ESP123",
      puntuacion: 3,
      save: jest.fn(),
      toJSON: jest.fn().mockReturnValue({}),
    });

    const res = await request(app)
      .put("/api/v1/calificaciones/CAL123")
      .set("Authorization", "Bearer token")
      .send({ puntuacion: 4 });

    expect(res.statusCode).toBe(403);
    expect(res.body.message).toBe("No autorizado para editar");
  });

  // ============================================================
  // 3) ❌ Puntuación inválida → 400
  // ============================================================
  test("Debe devolver 400 si la puntuación es menor a 1 o mayor a 5", async () => {
    Calificacion.findOne.mockResolvedValue({
      idCalificacion: "CAL123",
      idUsuario: "USER123",
      idEspacio: "ESP123",
      puntuacion: 3,
      save: jest.fn(),
    });

    const res = await request(app)
      .put("/api/v1/calificaciones/CAL123")
      .set("Authorization", "Bearer token")
      .send({ puntuacion: 10 }); // ❌ inválida

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toBe("La puntuación debe estar entre 1 y 5");
  });

  // ============================================================
  // 4) ✅ Actualización exitosa → 200 + promedio actualizado
  // ============================================================
  test("Debe actualizar la calificación y recalcular el promedio (200)", async () => {
    const mockSave = jest.fn();

    Calificacion.findOne.mockResolvedValue({
      idCalificacion: "CAL123",
      idUsuario: "USER123",
      idEspacio: "ESP123",
      puntuacion: 3,
      comentario: "Original",
      save: mockSave,
      toJSON: jest.fn().mockReturnValue({
        idCalificacion: "CAL123",
        puntuacion: 5,
        comentario: "Editado",
      }),
    });

    // Mock del aggregate → promedio final = 4
    Calificacion.aggregate = jest.fn().mockResolvedValue([
      { promedio: 4 },
    ]);

    Espacio.updateOne = jest.fn().mockResolvedValue({});

    const res = await request(app)
      .put("/api/v1/calificaciones/CAL123")
      .set("Authorization", "Bearer token")
      .send({ puntuacion: 5, comentario: "Editado" });

    expect(res.statusCode).toBe(200);
    expect(mockSave).toHaveBeenCalled();

    expect(res.body).toEqual({
      message: "Calificación actualizada",
      calificacion: {
        idCalificacion: "CAL123",
        puntuacion: 5,
        comentario: "Editado",
      },
      promedioCalificacion: 4,
    });
  });
});
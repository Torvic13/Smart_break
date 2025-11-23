const request = require("supertest");
const app = require("../src/app.js");
const mongoose = require("mongoose");

describe("POST /api/v1/calificaciones", () => {

  afterAll(async () => {
    await mongoose.connection.close();
  });

  test("Debe crear o actualizar una calificación", async () => {
    const login = await request(app)
      .post('/api/v1/auth/login')
      .send({
        correo: "admin@smartbreak.com",
        password: "admin123",
      });

    expect(login.statusCode).toBe(200);
    const token = login.body.token;

    const res = await request(app)
      .post('/api/v1/calificaciones')
      .set('Authorization', `Bearer ${token}`)
      .send({
        puntuacion: 4,
        comentario: "Muy buen lugar",
        idEspacio: "1"
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("calificacion");
  });

});

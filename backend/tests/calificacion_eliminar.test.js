const request = require("supertest");
const app = require("../src/app.js");
const mongoose = require("mongoose");

let token = "";
let idCalificacion = "";

describe("DELETE /api/v1/calificaciones/:idCalificacion", () => {

  beforeAll(async () => {
    const login = await request(app)
      .post('/api/v1/auth/login')
      .send({
        correo: "admin@smartbreak.com",
        password: "admin123"
      });

    expect(login.statusCode).toBe(200);
    token = login.body.token;

    const res = await request(app)
      .post('/api/v1/calificaciones')
      .set('Authorization', `Bearer ${token}`)
      .send({
        puntuacion: 2,
        comentario: "Temporal",
        idEspacio: "1"
      });

    idCalificacion = res.body.calificacion.idCalificacion;
  });

  it("Debe eliminar (soft delete) la calificación", async () => {
    const res = await request(app)
      .delete(`/api/v1/calificaciones/${idCalificacion}`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe("Calificación eliminada");
  });
});

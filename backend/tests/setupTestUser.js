const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const Usuario = require("../src/models/user_model");

module.exports = async () => {
  await mongoose.connection.dropDatabase();

  const hash = await bcrypt.hash("admin123", 10);

  await Usuario.create({
    nombre: "Admin Test",
    correo: "admin@smartbreak.com",
    passwordHash: hash,
    rol: "admin"
  });

  console.log("✔ Usuario admin de test creado");
};

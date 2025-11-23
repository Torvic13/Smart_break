const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  correo: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  rol: { type: String, default: "usuario" }
}, {
  timestamps: true
});

module.exports = mongoose.model("Usuario", UserSchema);

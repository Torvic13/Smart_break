const Espacio = require("../src/models/espacio_model");

module.exports = async () => {
  await Espacio.create({
    idEspacio: "1",
    nombre: "Espacio Test",
    tipo: "sala",
    ubicacion: { latitud: 0, longitud: 0 },
    capacidad: 10
  });

  console.log("✔ Espacio de test creado");
};

const mongoose = require('mongoose');
require('dotenv').config();

async function connectDB() {
  try {
    const uri = process.env.NODE_ENV === "test"
      ? process.env.MONGO_URI               // usa .env.test
      : process.env.MONGO_URI;

    await mongoose.connect(uri);

    console.log(`✅ MongoDB conectado: ${uri}`);
  } catch (err) {
    console.error('❌ Error al conectar a MongoDB:', err.message);
    process.exit(1);
  }
}

module.exports = connectDB;

require('dotenv').config();
const app = require('./app');
const connectDB = require('./database');

async function main() {
  await connectDB();
  app.listen(process.env.PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${process.env.PORT}`);
  });
}

main();

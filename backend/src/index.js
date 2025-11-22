const app = require('./app');
const connectDB = require('./database');

async function main() {
  await connectDB();
  app.listen(4000, () => {
    console.log('🚀 Servidor corriendo en http://localhost:4000');
  });
}

main();

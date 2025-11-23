const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.use('/api/v1/auth', require('./routes/auth_routes'));
app.use('/api/v1/calificaciones', require('./routes/calificacion_routes'));
app.use('/api/v1/espacios', require('./routes/espacio_routes'));

module.exports = app;

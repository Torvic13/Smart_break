// src/tests/reporte_ocupacion_unit.test.js
const {
  puedeReportarEspacio,
  puedeReportarHoy,
} = require('../utils/control_abuso_reportes'); // Ajusta la ruta si tienes un archivo de utils

// Si no tienes utils, copia estas funciones aquí abajo (ver más abajo)

describe('PRUEBAS UNITARIAS - HU22 Control de abuso en reportes', () => {
  test('Debe permitir reportar si no ha reportado ese espacio en los últimos 15 minutos', () => {
    const ultimoReportePorEspacio = new Map();
    ultimoReportePorEspacio.set('biblio-1', Date.now() - 20 * 60 * 1000); // Hace 20 min

    const resultado = puedeReportarEspacio('biblio-1', ultimoReportePorEspacio);
    expect(resultado.permitido).toBe(true);
  });

  test('Debe BLOQUEAR si reportó el mismo espacio hace menos de 15 minutos', () => {
    const ultimoReportePorEspacio = new Map();
    ultimoReportePorEspacio.set('biblio-1', Date.now() - 5 * 60 * 1000); // Hace 5 min

    const resultado = puedeReportarEspacio('biblio-1', ultimoReportePorEspacio);
    expect(resultado.permitido).toBe(false);
    expect(resultado.mensaje).toContain('Espera');
  });

  test('Debe permitir reportar otro espacio aunque haya reportado uno hace poco', () => {
    const ultimoReportePorEspacio = new Map();
    ultimoReportePorEspacio.set('biblio-1', Date.now() - 2 * 60 * 1000);

    const resultado = puedeReportarEspacio('cafeteria-1', ultimoReportePorEspacio);
    expect(resultado.permitido).toBe(true);
  });

  test('Debe permitir hasta 10 reportes por día', () => {
    const usuario = {
      reportesHoy: 9,
      ultimoResetDiario: new Date(),
    };

    expect(puedeReportarHoy(usuario)).toBe(true);
  });

  test('Debe BLOQUEAR al llegar a 10 reportes diarios', () => {
    const usuario = {
      reportesHoy: 10,
      ultimoResetDiario: new Date(),
    };

    expect(puedeReportarHoy(usuario)).toBe(false);
  });
});
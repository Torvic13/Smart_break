// src/utils/control_abuso_reportes.js
const QUINCE_MINUTOS = 15 * 60 * 1000; // 15 minutos en milisegundos
const LIMITE_DIARIO = 10;

function puedeReportarEspacio(espacioId, ultimoReportePorEspacio) {
  const ultimoReporte = ultimoReportePorEspacio.get(espacioId);
  
  if (!ultimoReporte) {
    return { permitido: true };
  }

  const ahora = Date.now();
  const tiempoTranscurrido = ahora - ultimoReporte;

  if (tiempoTranscurrido < QUINCE_MINUTOS) {
    return {
      permitido: false,
      mensaje: `Espera ${Math.ceil((QUINCE_MINUTOS - tiempoTranscurrido) / 60000)} minutos para reportar este espacio de nuevo`,
    };
  }

  return { permitido: true };
}

function puedeReportarHoy(usuario) {
  // Resetea contador si pasó un día
  const hoy = new Date().setHours(0, 0, 0, 0);
  const ultimoReset = new Date(usuario.ultimoResetDiario).setHours(0, 0, 0, 0);

  if (hoy > ultimoReset) {
    usuario.reportesHoy = 0;
    usuario.ultimoResetDiario = new Date();
  }

  return usuario.reportesHoy < LIMITE_DIARIO;
}

module.exports = {
  puedeReportarEspacio,
  puedeReportarHoy,
};
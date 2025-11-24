// src/controllers/reporte_ocupacion_controller.js
const Usuario = require('../models/user_model');
const ReporteOcupacion = require('../models/reporte_ocupacion_model');

const crearReporte = async (req, res) => {
  try {
    const usuarioId = req.user.id; // Viene del requireAuth
    const { espacioId, nivelOcupacion } = req.body;

    if (!espacioId || !nivelOcupacion) {
      return res.status(400).json({ message: 'Faltan datos' });
    }

    const usuario = await Usuario.findById(usuarioId);
    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });

    // === RESET DIARIO ===
    const hoy = new Date();
    const inicioDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());
    if (!usuario.ultimoResetDiario || usuario.ultimoResetDiario < inicioDelDia) {
      usuario.reportesHoy = 0;
      usuario.ultimoResetDiario = new Date();
    }

    // === LÍMITE DIARIO: 10 reportes por día ===
    if (usuario.reportesHoy >= 10) {
      return res.status(429).json({
        bloqueado: true,
        message: 'Has alcanzado el límite diario de 10 reportes. Vuelve mañana.'
      });
    }

    // === LÍMITE POR TIEMPO: 15 minutos por espacio ===
    const ultimoReporte = usuario.ultimoReportePorEspacio.get(espacioId);
    if (ultimoReporte) {
      const diferencia = Date.now() - new Date(ultimoReporte);
      if (diferencia < 15 * 60 * 1000) { // 15 minutos
        const minutosFaltan = Math.ceil((15 * 60 * 1000 - diferencia) / 60000);
        return res.status(429).json({
          bloqueado: true,
          message: `Ya reportaste este lugar. Espera ${minutosFaltan} minuto${minutosFaltan > 1 ? 's' : ''}.`
        });
      }
    }

    // === GUARDAR REPORTE ===
    const reporte = new ReporteOcupacion({
      usuarioId,
      espacioId,
      nivelOcupacion
    });
    await reporte.save();

    // === ACTUALIZAR CONTADORES DEL USUARIO ===
    usuario.ultimoReportePorEspacio.set(espacioId, new Date());
    usuario.reportesHoy += 1;
    await usuario.save();

    res.status(201).json({
      success: true,
      message: 'Reporte enviado correctamente',
      reporte
    });

  } catch (error) {
    console.error('Error al reportar ocupación:', error);
    res.status(500).json({ message: 'Error del servidor' });
  }
};

module.exports = { crearReporte };
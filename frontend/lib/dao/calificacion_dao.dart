import '../models/calificacion.dart';

abstract class CalificacionDAO {
  Future<Calificacion> crearCalificacion({
    required String idEspacio,
    required double puntuacion,
    required String comentario,
    required String authToken,
  });

  Future<List<Calificacion>> obtenerCalificacionesPorEspacio({
    required String idEspacio,
    required String authToken,
  });

  Future<List<Calificacion>> obtenerCalificacionesPorUsuario({
    required String idUsuario,
    required String authToken,
  });

  // 👇 AGREGAR ESTOS MÉTODOS QUE FALTAN
  Future<void> eliminarCalificacion({
    required String idCalificacion,
    required String authToken,
  });

  Future<Calificacion> actualizarCalificacion({
    required String idCalificacion,
    required double puntuacion,
    required String comentario,
    required String authToken,
  });
}
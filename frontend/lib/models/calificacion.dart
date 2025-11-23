enum EstadoCalificacion { pendiente, aprobada, rechazada }

class Calificacion {
  String idCalificacion;
  String? idEspacio; // del backend
  String? idUsuario; // del backend
  int puntuacion;
  String comentario;
  DateTime fecha;
  EstadoCalificacion estado;

  Calificacion({
    required this.idCalificacion,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
    this.estado = EstadoCalificacion.pendiente,
    this.idEspacio,
    this.idUsuario,
  });

  /// Permite editar campos dinámicamente (útil en DAO mock)
  void editar(Map<String, dynamic> nuevosDatos) {
    if (nuevosDatos.containsKey('puntuacion')) {
      puntuacion = nuevosDatos['puntuacion'];
    }
    if (nuevosDatos.containsKey('comentario')) {
      comentario = nuevosDatos['comentario'];
    }
    if (nuevosDatos.containsKey('estado')) {
      estado = nuevosDatos['estado'];
    }
  }

  /// Convierte el objeto a JSON (para almacenamiento local, etc.)
  Map<String, dynamic> toJson() {
    return {
      'idCalificacion': idCalificacion,
      'idEspacio': idEspacio,
      'idUsuario': idUsuario,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
      'estado': estado.name,
    };
  }

  /// Crea un objeto desde JSON (soporta `fecha` o `fechaCreacion`)
  factory Calificacion.fromJson(Map<String, dynamic> json) {
    final fechaStr =
        (json['fecha'] ?? json['fechaCreacion']) as String? ?? '';

    final estadoStr = (json['estado'] as String?) ?? 'aprobada';

    return Calificacion(
      idCalificacion: json['idCalificacion'] as String,
      idEspacio: json['idEspacio'] as String?,
      idUsuario: json['idUsuario'] as String?,
      puntuacion: json['puntuacion'] as int,
      comentario: json['comentario'] as String? ?? '',
      fecha: fechaStr.isNotEmpty
          ? DateTime.parse(fechaStr)
          : DateTime.now(),
      estado: EstadoCalificacion.values.firstWhere(
        (e) => e.name == estadoStr,
        orElse: () => EstadoCalificacion.pendiente,
      ),
    );
  }
}

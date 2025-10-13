enum EstadoCalificacion { pendiente, aprobada, rechazada }

class Calificacion {
  String idCalificacion;
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

  /// Convierte el objeto a JSON (para almacenamiento o red)
  Map<String, dynamic> toJson() {
    return {
      'idCalificacion': idCalificacion,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
      'estado': estado.name,
    };
  }

  /// Crea un objeto desde JSON
  factory Calificacion.fromJson(Map<String, dynamic> json) {
    return Calificacion(
      idCalificacion: json['idCalificacion'],
      puntuacion: json['puntuacion'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
      estado: EstadoCalificacion.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoCalificacion.pendiente,
      ),
    );
  }
}
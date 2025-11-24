enum EstadoCalificacion { pendiente, aprobada, rechazada }

class Calificacion {
  String idCalificacion;
  String? idEspacio;
  String? idUsuario;

  String? codigoAlumno;   // viene del usuario
  String? nombreUsuario;  // nombreCompleto
  String? nombreEspacio;  // 👈 nuevo campo

  int puntuacion;
  String comentario;
  DateTime fecha;
  EstadoCalificacion estado;

  Calificacion({
    required this.idCalificacion,
    this.idEspacio,
    this.idUsuario,
    this.codigoAlumno,
    this.nombreUsuario,
    this.nombreEspacio,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
    this.estado = EstadoCalificacion.pendiente,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'idCalificacion': idCalificacion,
      'idEspacio': idEspacio,
      'idUsuario': idUsuario,
      'codigoAlumno': codigoAlumno,
      'nombreCompleto': nombreUsuario,
      'nombreEspacio': nombreEspacio,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
      'estado': estado.name,
    };
  }

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    String? _s(dynamic v) => v == null ? null : v.toString();

    final fechaStr = _s(json['fechaCreacion'] ?? json['fecha']);
    final fecha = fechaStr != null ? DateTime.parse(fechaStr) : DateTime.now();

    return Calificacion(
      idCalificacion: _s(json['idCalificacion']) ?? '',
      idEspacio: _s(json['idEspacio']),
      idUsuario: _s(json['idUsuario']),
      codigoAlumno: _s(json['codigoAlumno']),
      nombreUsuario: _s(json['nombreCompleto']),
      nombreEspacio: _s(json['nombreEspacio']),
      puntuacion: (json['puntuacion'] as num?)?.toInt() ?? 0,
      comentario: (json['comentario'] ?? '') as String,
      fecha: fecha,
      estado: EstadoCalificacion.values.firstWhere(
        (e) => e.name == (json['estado'] ?? 'pendiente'),
        orElse: () => EstadoCalificacion.pendiente,
      ),
    );
  }
}

// lib/models/calificacion.dart
class Calificacion {
  final String idCalificacion;   // <-- nombre correcto
  final String idEspacio;
  final String idUsuario;
  final double puntuacion;
  final String comentario;
  final DateTime fecha;

  Calificacion({
    required this.idCalificacion,
    required this.idEspacio,
    required this.idUsuario,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
  });

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    return Calificacion(
      idCalificacion: (json['idCalificacion'] ?? '').toString(),
      idEspacio: (json['idEspacio'] ?? '').toString(),
      idUsuario: (json['idUsuario'] ?? '').toString(),
      puntuacion: (json['puntuacion'] ?? 0).toDouble(),
      comentario: json['comentario']?.toString() ?? '',
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCalificacion': idCalificacion,
      'idEspacio': idEspacio,
      'idUsuario': idUsuario,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }
}

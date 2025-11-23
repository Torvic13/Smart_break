class Incidencia {
  final String idIncidencia;
  final String idEspacio;
  final String nombreEspacio;
  final String tipoIncidencia;
  final String descripcion;
  final DateTime fechaReporte;
  final String usuarioReporte;
  final bool resuelta;
  final DateTime? fechaResolucion;
  final String notas;

  Incidencia({
    required this.idIncidencia,
    required this.idEspacio,
    required this.nombreEspacio,
    required this.tipoIncidencia,
    required this.descripcion,
    required this.fechaReporte,
    required this.usuarioReporte,
    this.resuelta = false,
    this.fechaResolucion,
    this.notas = '',
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      idIncidencia: json['idIncidencia'] as String,
      idEspacio: json['idEspacio'] as String? ?? '',
      nombreEspacio: json['nombreEspacio'] as String? ?? 'Espacio desconocido',
      tipoIncidencia: json['tipoIncidencia'] as String,
      descripcion: json['descripcion'] as String,
      fechaReporte: DateTime.parse(json['fechaReporte'] as String),
      usuarioReporte: json['usuarioReporte'] as String,
      resuelta: json['resuelta'] as bool? ?? false,
      fechaResolucion: json['fechaResolucion'] != null
          ? DateTime.parse(json['fechaResolucion'] as String)
          : null,
      notas: json['notas'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idIncidencia': idIncidencia,
      'idEspacio': idEspacio,
      'nombreEspacio': nombreEspacio,
      'tipoIncidencia': tipoIncidencia,
      'descripcion': descripcion,
      'fechaReporte': fechaReporte.toIso8601String(),
      'usuarioReporte': usuarioReporte,
      'resuelta': resuelta,
      'fechaResolucion': fechaResolucion?.toIso8601String(),
      'notas': notas,
    };
  }
}

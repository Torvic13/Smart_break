import 'espacio.dart';

class Ubicacion {
  final String idUbicacion;
  final double latitud;
  final double longitud;
  final int piso;

  Ubicacion({
    required this.idUbicacion,
    required this.latitud,
    required this.longitud,
    required this.piso,
  });

  List<Espacio> obtenerCercanos(double radioKm) {
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'idUbicacion': idUbicacion,
      'latitud': latitud,
      'longitud': longitud,
      'piso': piso,
    };
  }

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    final pisoRaw = json['piso'];

    return Ubicacion(
      idUbicacion: json['idUbicacion']?.toString() ?? '',
      latitud: (json['latitud'] is num)
          ? (json['latitud'] as num).toDouble()
          : double.parse(json['latitud'].toString()),
      longitud: (json['longitud'] is num)
          ? (json['longitud'] as num).toDouble()
          : double.parse(json['longitud'].toString()),
      piso: (pisoRaw is int)
          ? pisoRaw
          : int.tryParse(pisoRaw.toString()) ?? 0,
    );
  }
}
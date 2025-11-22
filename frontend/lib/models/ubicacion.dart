// models/ubicacion.dart
class Ubicacion {
  final double latitud;
  final double longitud;
  final String? piso;
  final String? edificio;

  Ubicacion({
    required this.latitud,
    required this.longitud,
    this.piso,
    this.edificio,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      latitud: (json['latitud'] ?? 0).toDouble(),
      longitud: (json['longitud'] ?? 0).toDouble(),
      piso: json['piso'],
      edificio: json['edificio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'piso': piso,
      'edificio': edificio,
    };
  }
}
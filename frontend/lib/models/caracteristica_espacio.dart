// lib/models/caracteristica_espacio.dart
class CaracteristicaEspacio {
  final String nombre;
  final String valor;

  CaracteristicaEspacio({
    required this.nombre,
    required this.valor,
  });

  factory CaracteristicaEspacio.fromJson(Map<String, dynamic> json) {
    return CaracteristicaEspacio(
      nombre: (json['nombre'] ?? '').toString(),
      valor: (json['valor'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'valor': valor,
    };
  }
}

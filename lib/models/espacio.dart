import 'ubicacion.dart';
import 'caracteristica_espacio.dart';

enum NivelOcupacion { vacio, bajo, medio, alto, lleno }

class Espacio {
  final String idEspacio;
  final String nombre;
  final String tipo;
  final NivelOcupacion nivelOcupacion;
  final double promedioCalificacion;
  final Ubicacion ubicacion;
  final List<CaracteristicaEspacio> caracteristicas;
  final List<String>? _categoriaIds;
  
  // Getter que garantiza que siempre devuelve una lista no-null
  List<String> get categoriaIds => _categoriaIds ?? [];

  Espacio({
    required this.idEspacio,
    required this.nombre,
    required this.tipo,
    required this.nivelOcupacion,
    required this.promedioCalificacion,
    required this.ubicacion,
    required this.caracteristicas,
    List<String>? categoriaIds,
  }) : _categoriaIds = categoriaIds ?? [];

  void actualizarOcupacion(String estado, String fuente) {
    // Mock implementation - no real functionality
  }

  void agregarCaracteristica(String idCaracteristica) {
    // Mock implementation - no real functionality
  }

  Map<String, dynamic> toJson() {
    return {
      'idEspacio': idEspacio,
      'nombre': nombre,
      'tipo': tipo,
      'nivelOcupacion': nivelOcupacion.name,
      'promedioCalificacion': promedioCalificacion,
      'ubicacion': ubicacion.toJson(),
      'caracteristicas': caracteristicas.map((c) => c.toJson()).toList(),
      'categoriaIds': _categoriaIds ?? [],
    };
  }

  factory Espacio.fromJson(Map<String, dynamic> json) {
    return Espacio(
      idEspacio: json['idEspacio'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      nivelOcupacion: NivelOcupacion.values.firstWhere(
        (e) => e.name == json['nivelOcupacion'],
        orElse: () => NivelOcupacion.medio,
      ),
      promedioCalificacion: json['promedioCalificacion'].toDouble(),
      ubicacion: Ubicacion.fromJson(json['ubicacion']),
      caracteristicas: (json['caracteristicas'] as List)
          .map((c) => CaracteristicaEspacio.fromJson(c))
          .toList(),
      categoriaIds: json['categoriaIds'] != null 
          ? List<String>.from(json['categoriaIds'])
          : [],
    );
  }
}

import 'package:smart_break/models/espacio.dart';
import 'package:smart_break/models/ubicacion.dart';
import 'usuario.dart';

class AdministradorSistema extends Usuario {
  AdministradorSistema({
    required super.idUsuario,
    required super.email,
    required super.passwordHash,
    required super.fechaCreacion,
    required super.estado,
  }) : super(
         rol: RolUsuario.admin, // se asigna directamente el rol admin
       );

  void crearEspacio(Map<String, dynamic> datosEspacio) {
    // Implementación futura
  }

  void categorizarEspacio(String espacioId, List<String> caracteristicas) {
    // Implementación futura
  }

  void reiniciarEstadoEspacios() {
    // Implementación futura
  }

  void moderarCalificacion(String califId, String estado) {
    // Implementación futura
  }

  void aplicarControlAbuso(String usuarioId) {
    // Implementación futura
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['rol'] = RolUsuario.admin.name; // guarda como 'admin'
    return json;
  }

  factory AdministradorSistema.fromJson(Map<String, dynamic> json) {
    return AdministradorSistema(
      idUsuario: json['idUsuario'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      estado: EstadoUsuario.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoUsuario.activo,
      ),
      // El rol se asigna internamente en el constructor
    );
  }
}

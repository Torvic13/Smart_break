import 'usuario.dart';

class AdministradorSistema extends Usuario {
  AdministradorSistema({
    required String idUsuario,
    required String email,
    required String passwordHash,
    required DateTime fechaCreacion,
    required EstadoUsuario estado,
  }) : super(
          idUsuario: idUsuario,
          email: email,
          passwordHash: passwordHash,
          fechaCreacion: fechaCreacion,
          estado: estado,
          rol: RolUsuario.admin,
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
    json['rol'] = RolUsuario.admin.name;
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
    );
  }
}
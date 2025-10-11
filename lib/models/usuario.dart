enum EstadoUsuario { activo, inactivo, suspendido }

enum RolUsuario { admin, estudiante }

class Usuario {
  final String idUsuario;
  final String email;
  final String passwordHash;
  final DateTime fechaCreacion;
  final EstadoUsuario estado;
  final RolUsuario rol;

  Usuario({
    required this.idUsuario,
    required this.email,
    required this.passwordHash,
    required this.fechaCreacion,
    required this.estado,
    required this.rol,
  });

  void editarPerfil(Map<String, dynamic> datos) {}

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'email': email,
      'passwordHash': passwordHash,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'estado': estado.name,
      'rol': rol.name,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      estado: EstadoUsuario.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoUsuario.activo,
      ),
      rol: RolUsuario.values.firstWhere(
        (r) => r.name == json['rol'],
        orElse: () => RolUsuario.estudiante,
      ),
    );
  }
}

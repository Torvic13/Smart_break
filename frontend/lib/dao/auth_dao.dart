import '../models/usuario.dart';

abstract class AuthDAO {
  /// Devuelve el usuario autenticado o null si credenciales inválidas
  Future<Usuario?> iniciarSesion({
    required String email,
    required String pass,
  });

  /// Crea la cuenta en el backend y devuelve el usuario creado
  Future<Usuario> crearCuenta(Map<String, dynamic> datos);
}

import '../models/usuario.dart';

abstract class AuthDAO {
  Future<bool> iniciarSesion({required String email, required String pass});
  Future<void> crearCuenta(Map<String, dynamic> datos);
}

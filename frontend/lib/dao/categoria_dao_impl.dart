import 'categoria_dao.dart';
import '../models/categoria_espacio.dart';

class CategoriaDAOImpl extends CategoriaDAO {
  @override
  Future<CategoriaEspacio?> obtenerPorId(String id) async {
    // Tu implementación aquí
    return null;
  }

  @override
  Future<List<CategoriaEspacio>> obtenerTodas() async {
    // Tu implementación aquí
    return [];
  }

  @override
  Future<List<CategoriaEspacio>> obtenerPorTipo(TipoCategoria tipo) async {
    // Tu implementación aquí
    return [];
  }

  @override
  Future<void> crear(CategoriaEspacio categoria) async {
    // Tu implementación aquí
  }

  @override
  Future<void> actualizar(CategoriaEspacio categoria) async {
    // Tu implementación aquí
  }

  @override
  Future<void> eliminar(String id) async {
    // Tu implementación aquí
  }

  @override
  Future<bool> existeCategoria(String nombre, TipoCategoria tipo) async {
    // Tu implementación aquí
    return false;
  }
}
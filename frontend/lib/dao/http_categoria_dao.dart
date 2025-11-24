import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_espacio.dart';
import 'categoria_dao.dart';
import 'auth_service.dart';

class HttpCategoriaDAO implements CategoriaDAO {
  final String baseUrl;

  HttpCategoriaDAO({this.baseUrl = 'http://10.0.2.2:4000/api/v1'});

  // Helper para headers con token opcional
  Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = AuthService().token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  @override
  Future<CategoriaEspacio?> obtenerPorId(String id) async {
    final uri = Uri.parse('$baseUrl/categorias/$id');
    final resp = await http.get(uri, headers: _headers());

    if (resp.statusCode == 404) return null;
    if (resp.statusCode != 200) {
      throw Exception('Error al obtener categoría: ${resp.statusCode}');
    }

    final json = jsonDecode(resp.body);
    return _parseCategoria(json);
  }

  @override
  Future<List<CategoriaEspacio>> obtenerTodas() async {
    final uri = Uri.parse('$baseUrl/categorias');
    final resp = await http.get(uri, headers: _headers());

    if (resp.statusCode != 200) {
      throw Exception('Error al listar categorías: ${resp.statusCode}');
    }

    final List<dynamic> list = jsonDecode(resp.body);
    return list.map((json) => _parseCategoria(json)).toList();
  }

  @override
  Future<List<CategoriaEspacio>> obtenerPorTipo(TipoCategoria tipo) async {
    final tipoBackend = _mapTipoToBackend(tipo);
    final uri = Uri.parse('$baseUrl/categorias?tipo=$tipoBackend');
    final resp = await http.get(uri, headers: _headers());

    if (resp.statusCode != 200) {
      throw Exception('Error al listar categorías por tipo: ${resp.statusCode}');
    }

    final List<dynamic> list = jsonDecode(resp.body);
    return list.map((json) => _parseCategoria(json)).toList();
  }

  @override
  Future<void> crear(CategoriaEspacio categoria) async {
    final uri = Uri.parse('$baseUrl/categorias');
    
    // Mapeo del tipo del frontend al backend
    final tipoBackend = _mapTipoToBackend(categoria.tipo);
    
    final body = {
      'nombre': categoria.nombre,
      'tipo': tipoBackend,
      'descripcion': categoria.nombre,
      'icono': 'category',
      'activa': true,
    };
    
    print('httpCategoriaDAO.crear() - Enviando a: $uri');
    print('Body: $body');
    print('Token: ${AuthService().token}');
    
    final resp = await http.post(
      uri,
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );

    print('Respuesta status: ${resp.statusCode}');
    print('Respuesta body: ${resp.body}');

    if (resp.statusCode != 201) {
      throw Exception('Error al crear categoría: ${resp.statusCode} - ${resp.body}');
    }
  }

  // Mapeo de tipos frontend -> backend
  String _mapTipoToBackend(TipoCategoria tipo) {
    switch (tipo) {
      case TipoCategoria.tipoEspacio:
        return 'tipoEspacio';
      case TipoCategoria.nivelRuido:
        return 'nivelRuido';
      case TipoCategoria.comodidad:
        return 'comodidad';
      case TipoCategoria.capacidad:
        return 'capacidad';
      case TipoCategoria.bloqueHorario:
        return 'bloqueHorario';
    }
  }

  // Mapeo de tipos backend -> frontend
  TipoCategoria _mapTipoFromBackend(String tipo) {
    switch (tipo) {
      case 'tipoEspacio':
        return TipoCategoria.tipoEspacio;
      case 'nivelRuido':
        return TipoCategoria.nivelRuido;
      case 'comodidad':
        return TipoCategoria.comodidad;
      case 'capacidad':
        return TipoCategoria.capacidad;
      case 'bloqueHorario':
        return TipoCategoria.bloqueHorario;
      default:
        return TipoCategoria.tipoEspacio;
    }
  }

  @override
  Future<void> actualizar(CategoriaEspacio categoria) async {
    final uri = Uri.parse('$baseUrl/categorias/${categoria.idCategoria}');
    final resp = await http.put(
      uri,
      headers: _headers(auth: true),
      body: jsonEncode({
        'nombre': categoria.nombre,
        'descripcion': categoria.nombre,
        'activa': true,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error al actualizar categoría: ${resp.statusCode}');
    }
  }

  @override
  Future<void> eliminar(String id) async {
    final uri = Uri.parse('$baseUrl/categorias/$id');
    
    print('Eliminando categoría: $id');
    print('URL: $uri');
    print('Token: ${AuthService().token}');
    
    final resp = await http.delete(uri, headers: _headers(auth: true));

    print('Respuesta status: ${resp.statusCode}');
    print('Respuesta body: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Error al eliminar categoría: ${resp.statusCode} - ${resp.body}');
    }
  }

  @override
  Future<bool> existeCategoria(String nombre, TipoCategoria tipo) async {
    try {
      final categorias = await obtenerPorTipo(tipo);
      return categorias.any((cat) => 
        cat.nombre.toLowerCase() == nombre.toLowerCase()
      );
    } catch (e) {
      return false;
    }
  }

  // Parser del backend al modelo frontend
  CategoriaEspacio _parseCategoria(Map<String, dynamic> json) {
    final tipoStr = json['tipo'] ?? 'tipoEspacio';
    return CategoriaEspacio(
      idCategoria: json['idCategoria'] ?? json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      tipo: _mapTipoFromBackend(tipoStr),
      fechaCreacion: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/espacio.dart';
import '../models/categoria_espacio.dart';
import '../dao/dao_factory.dart';
import '../dao/espacio_dao.dart';
import '../models/nivel_ocupacion.dart';
import '../dao/categoria_dao.dart';

class FilteredSpacesScreen extends StatefulWidget {
  const FilteredSpacesScreen({Key? key}) : super(key: key);

  @override
  State<FilteredSpacesScreen> createState() => _FilteredSpacesScreenState();
}

class _FilteredSpacesScreenState extends State<FilteredSpacesScreen> {
  late EspacioDAO _espacioDao;
  late CategoriaDAO _categoriaDao;
  bool _daoInicializado = false;

  List<Espacio> _espacios = [];
  List<CategoriaEspacio> _categorias = [];
  Set<String> _categoriasSeleccionadas = {};

  // Función para convertir String a NivelOcupacion
  NivelOcupacion _stringToNivelOcupacion(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'vacío':
      case 'vacio':
        return NivelOcupacion.vacio;
      case 'bajo':
        return NivelOcupacion.bajo;
      case 'medio':
        return NivelOcupacion.medio;
      case 'alto':
        return NivelOcupacion.alto;
      case 'lleno':
        return NivelOcupacion.lleno;
      default:
        return NivelOcupacion.vacio;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_daoInicializado) {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      _espacioDao = daoFactory.createEspacioDAO();
      _categoriaDao = daoFactory.createCategoriaDAO();
      _daoInicializado = true;

      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    try {
      final espacios = await _espacioDao.obtenerTodos();
      final categorias = await _categoriaDao.obtenerTodas();

      setState(() {
        _espacios = espacios;
        _categorias = categorias;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
  }

  List<Espacio> _filtrarEspacios() {
    if (_categoriasSeleccionadas.isEmpty) {
      return _espacios;
    }

    return _espacios.where((espacio) {
      // Verifica si el espacio tiene al menos una de las categorías seleccionadas
      return espacio.categoriaIds.any(
        (categoriaId) => _categoriasSeleccionadas.contains(categoriaId),
      );
    }).toList();
  }

  void _toggleCategoria(String categoriaId) {
    setState(() {
      if (_categoriasSeleccionadas.contains(categoriaId)) {
        _categoriasSeleccionadas.remove(categoriaId);
      } else {
        _categoriasSeleccionadas.add(categoriaId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final espaciosFiltrados = _filtrarEspacios();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar por Categorías'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Sección de filtros de categorías
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Filtrar por categorías:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _categorias.map((categoria) {
                    final isSelected =
                        _categoriasSeleccionadas.contains(categoria.idCategoria);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(categoria.nombre),
                      onSelected: (bool selected) {
                        _toggleCategoria(categoria.idCategoria);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          // Lista de espacios filtrados
          Expanded(
            child: ListView.builder(
              itemCount: espaciosFiltrados.length,
              itemBuilder: (context, index) {
                final espacio = espaciosFiltrados[index];
                final nivelOcupacion = _stringToNivelOcupacion(espacio.nivelOcupacion);
                final categoriasEspacio = _categorias
                    .where((c) => espacio.categoriaIds.contains(c.idCategoria))
                    .map((c) => c.nombre)
                    .join(', ');

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(espacio.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo: ${espacio.tipo}'),
                        Text('Categorías: $categoriasEspacio'),
                        Text('Ocupación: ${_getOcupacionText(nivelOcupacion)}'),
                      ],
                    ),
                    trailing: Icon(_getIconForOcupacion(nivelOcupacion)),
                    onTap: () {
                      // Navegar al detalle del espacio si es necesario
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForOcupacion(NivelOcupacion nivel) {
    switch (nivel) {
      case NivelOcupacion.vacio:
        return Icons.brightness_1_outlined;
      case NivelOcupacion.bajo:
        return Icons.brightness_2;
      case NivelOcupacion.medio:
        return Icons.brightness_3;
      case NivelOcupacion.alto:
        return Icons.brightness_4;
      case NivelOcupacion.lleno:
        return Icons.brightness_5;
    }
  }

  String _getOcupacionText(NivelOcupacion nivel) {
    switch (nivel) {
      case NivelOcupacion.vacio:
        return 'Vacío';
      case NivelOcupacion.bajo:
        return 'Bajo';
      case NivelOcupacion.medio:
        return 'Medio';
      case NivelOcupacion.alto:
        return 'Alto';
      case NivelOcupacion.lleno:
        return 'Lleno';
    }
  }
}
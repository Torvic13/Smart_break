import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/espacio.dart';
import '../models/categoria_espacio.dart';
import '../dao/dao_factory.dart';
import '../dao/espacio_dao.dart';
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
  bool _filtrosExpandidos = true;

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

  Map<String, List<CategoriaEspacio>> _agruparCategorias() {
    final grupos = <String, List<CategoriaEspacio>>{
      'Tipos de Espacio': [],
      'Nivel de Ruido': [],
      'Servicios': [],
      'Tamaño de Grupo': [],
      'Horario': [],
    };

    for (var categoria in _categorias) {
      final nombre = categoria.nombre.toLowerCase();
      
      if (nombre.contains('estudio') || nombre.contains('biblioteca') || 
          nombre.contains('cafetería') || nombre.contains('patio') || 
          nombre.contains('sala') || nombre.contains('auditorio') ||
          nombre.contains('jardín') || nombre.contains('comprobadora')) {
        grupos['Tipos de Espacio']!.add(categoria);
      } else if (nombre.contains('silencioso') || nombre.contains('moderado') || 
                 nombre.contains('ruidoso')) {
        grupos['Nivel de Ruido']!.add(categoria);
      } else if (nombre.contains('aire acondicionado') || nombre.contains('enchufes') || 
                 nombre.contains('computadora') || nombre.contains('wifi')) {
        grupos['Servicios']!.add(categoria);
      } else if (nombre.contains('individual') || nombre.contains('pequeño') || 
                 nombre.contains('grupo grande')) {
        grupos['Tamaño de Grupo']!.add(categoria);
      } else if (nombre.contains('mañana') || nombre.contains('tarde') || 
                 nombre.contains('noche')) {
        grupos['Horario']!.add(categoria);
      }
    }

    return grupos..removeWhere((_, v) => v.isEmpty);
  }

  Widget _buildFilterSection(String title, List<CategoriaEspacio> categorias) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: categorias.map((categoria) {
            final isSelected =
                _categoriasSeleccionadas.contains(categoria.idCategoria);
            return FilterChip(
              selected: isSelected,
              label: Text(categoria.nombre),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.orange[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.grey[700],
              ),
              onSelected: (bool selected) {
                _toggleCategoria(categoria.idCategoria);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final espaciosFiltrados = _filtrarEspacios();
    final gruposCategorias = _agruparCategorias();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar por Categorías'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Sección de filtros colapsables
          ExpansionTile(
            title: const Text(
              'Filtrar por categorías',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            initiallyExpanded: _filtrosExpandidos,
            onExpansionChanged: (expanded) {
              setState(() {
                _filtrosExpandidos = expanded;
              });
            },
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...gruposCategorias.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildFilterSection(entry.key, entry.value),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 0),
          // Lista de espacios filtrados - EXPANDIDA
          Expanded(
            child: espaciosFiltrados.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No se encontraron espacios con los filtros seleccionados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: espaciosFiltrados.length,
                    itemBuilder: (context, index) {
                      final espacio = espaciosFiltrados[index];
                      final categoriasEspacio = _categorias
                          .where((c) =>
                              espacio.categoriaIds.contains(c.idCategoria))
                          .map((c) => c.nombre)
                          .join(', ');

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 6.0),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          title: Text(
                            espacio.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categoriasEspacio,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          trailing: Icon(
                            _getIconForOcupacion(espacio.nivelOcupacion),
                            color: Colors.orange,
                          ),
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
}

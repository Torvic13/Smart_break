import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria_espacio.dart';
import '../models/espacio.dart';
import '../dao/dao_factory.dart';
import '../dao/categoria_dao.dart';
import '../dao/espacio_dao.dart';
import '../models/nivel_ocupacion.dart';
import 'detalle_espacio_categorias_screen.dart';
import 'admin_categorias_screen.dart';

class GestionarCategoriasScreen extends StatefulWidget {
  const GestionarCategoriasScreen({Key? key}) : super(key: key);

  @override
  State<GestionarCategoriasScreen> createState() =>
      _GestionarCategoriasScreenState();
}

class _GestionarCategoriasScreenState extends State<GestionarCategoriasScreen> {
  late CategoriaDAO _categoriaDAO;
  late EspacioDAO _espacioDAO;
  bool _daoInicializado = false;

  Map<TipoCategoria, List<CategoriaEspacio>> _categoriasPorTipo = {};

  final Map<TipoCategoria, TextEditingController> _controllers = {};

  List<Espacio> _espacios = [];
  Espacio? _espacioSeleccionado;

  Set<String> _categoriasSeleccionadas = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (var tipo in TipoCategoria.values) {
      _controllers[tipo] = TextEditingController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_daoInicializado) {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      _categoriaDAO = daoFactory.createCategoriaDAO();
      _espacioDAO = daoFactory.createEspacioDAO();
      _daoInicializado = true;

      _cargarDatos();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tempMap = <TipoCategoria, List<CategoriaEspacio>>{};

      for (var tipo in TipoCategoria.values) {
        final categorias = await _categoriaDAO.obtenerPorTipo(tipo);
        tempMap[tipo] = categorias;
      }

      final espacios = await _espacioDAO.obtenerTodos();

      setState(() {
        _categoriasPorTipo = tempMap;
        _espacios = espacios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarCategorias() async {
    await _cargarDatos();
  }

  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _asignarCategoriasAEspacio() async {
    if (_espacioSeleccionado == null) {
      _mostrarSnackBar('Selecciona un espacio primero', esError: true);
      return;
    }

    setState(() {
      _categoriasSeleccionadas =
          Set<String>.from(_espacioSeleccionado!.categoriaIds);
    });

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.category_outlined,
                    color: Color(0xFFF97316), size: 28),
                SizedBox(width: 10),
                Text(
                  'Asignar Categorías',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espacio: ${_espacioSeleccionado!.nombre}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...TipoCategoria.values.map((tipo) {
                    final lista = _categoriasPorTipo[tipo] ?? [];
                    if (lista.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipo.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: lista.map((cat) {
                            final isSelected = _categoriasSeleccionadas
                                .contains(cat.idCategoria);

                            return FilterChip(
                              label: Text(cat.nombre),
                              selected: isSelected,
                              selectedColor:
                                  const Color(0xFFF97316).withOpacity(0.2),
                              checkmarkColor: const Color(0xFFF97316),
                              onSelected: (value) {
                                setStateDialog(() {
                                  if (value) {
                                    _categoriasSeleccionadas
                                        .add(cat.idCategoria);
                                  } else {
                                    _categoriasSeleccionadas
                                        .remove(cat.idCategoria);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316)),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (resultado == true) {
      await _guardarCategoriasDeEspacio();
    }
  }

  Future<void> _guardarCategoriasDeEspacio() async {
    if (_espacioSeleccionado == null) return;

    try {
      final espacioActualizado = Espacio(
        idEspacio: _espacioSeleccionado!.idEspacio,
        nombre: _espacioSeleccionado!.nombre,
        tipo: _espacioSeleccionado!.tipo,
        descripcion: _espacioSeleccionado!.descripcion,
        capacidad: _espacioSeleccionado!.capacidad,
        nivelOcupacion: _espacioSeleccionado!.nivelOcupacion,
        promedioCalificacion: _espacioSeleccionado!.promedioCalificacion,
        ubicacion: _espacioSeleccionado!.ubicacion,
        caracteristicas: _espacioSeleccionado!.caracteristicas,
        categoriaIds: _categoriasSeleccionadas.toList(),
        calificaciones: _espacioSeleccionado!.calificaciones,
      );

      await _espacioDAO.actualizar(espacioActualizado);

      setState(() {
        final index = _espacios.indexWhere(
            (e) => e.idEspacio == espacioActualizado.idEspacio);
        if (index != -1) _espacios[index] = espacioActualizado;
        _espacioSeleccionado = espacioActualizado;
      });

      _mostrarSnackBar('Categorías actualizadas correctamente');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetalleEspacioCategoriasScreen(espacio: espacioActualizado),
        ),
      );
    } catch (e) {
      _mostrarSnackBar('Error al guardar: $e', esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gestionar Categorías'),
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _cargarCategorias,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              DropdownButtonFormField<Espacio>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                value: _espacioSeleccionado,
                                items: _espacios.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.nombre),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _espacioSeleccionado = value;
                                  });
                                },
                                hint: const Text("Selecciona un espacio"),
                              ),
                              if (_espacioSeleccionado != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 4),
                                  child: Text(
                                    '${_espacioSeleccionado!.categoriaIds.length} categoría(s) asignada(s)',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _espacioSeleccionado == null
                              ? null
                              : _asignarCategoriasAEspacio,
                          icon: const Icon(Icons.edit),
                          label: const Text("Asignar Categorías"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminCategoriasScreen()),
                            ).then((_) => _cargarCategorias());
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text("Gestionar Categorías"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

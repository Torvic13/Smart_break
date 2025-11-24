import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria_espacio.dart';
import '../models/espacio.dart';
import '../dao/dao_factory.dart';
import '../dao/categoria_dao.dart';
import '../dao/espacio_dao.dart';
import '../dao/auth_service.dart';
import 'detalle_espacio_categorias_screen.dart';
import 'admin_categorias_screen.dart';

/// Pantalla para gestionar categorías de espacios
/// Solo accesible para administradores
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

  // Mapa para almacenar categorías por tipo
  Map<TipoCategoria, List<CategoriaEspacio>> _categoriasPorTipo = {};

  // Mapa para almacenar controladores de texto por tipo
  final Map<TipoCategoria, TextEditingController> _controllers = {};

  // Para el flujo de asignación por espacio
  List<Espacio> _espacios = [];
  Espacio? _espacioSeleccionado;
  Set<String> _categoriasSeleccionadas = {};
  bool _dropdownInteractuado = false;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores para cada tipo de categoría
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
    // Limpiar todos los controladores
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Carga todas las categorías y espacios desde el DAO
  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar categorías para cada tipo
      final Map<TipoCategoria, List<CategoriaEspacio>> tempMap = {};

      for (var tipo in TipoCategoria.values) {
        final categorias = await _categoriaDAO.obtenerPorTipo(tipo);
        tempMap[tipo] = categorias;
      }

      // Cargar espacios
      final espacios = await _espacioDAO.obtenerTodos();

      setState(() {
        _categoriasPorTipo = tempMap;
        _espacios = espacios;
        
        // Validar que el espacio seleccionado aún existe en la lista
        if (_espacioSeleccionado != null) {
          final existeEnLista = espacios.any(
            (e) => e.idEspacio == _espacioSeleccionado!.idEspacio
          );
          if (!existeEnLista) {
            _espacioSeleccionado = null;
            _categoriasSeleccionadas.clear();
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  /// Carga todas las categorías desde el DAO (para refresh)
  Future<void> _cargarCategorias() async {
    await _cargarDatos();
  }

  /// Muestra un SnackBar con un mensaje
  void _mostrarSnackBar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Abre el diálogo para asignar categorías al espacio seleccionado
  Future<void> _asignarCategoriasAEspacio() async {
    if (_espacioSeleccionado == null) {
      _mostrarSnackBar('Selecciona un espacio primero', esError: true);
      return;
    }

    // Cargar categorías actuales del espacio de forma segura
    setState(() {
      _categoriasSeleccionadas = {
        for (var id in _espacioSeleccionado!.categoriaIds) id
      };
    });

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    color: Color(0xFFF97316),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Asignar Categorías',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Espacio: ${_espacioSeleccionado!.nombre}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecciona las categorías:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mostrar categorías agrupadas por tipo
                  ...TipoCategoria.values.map((tipo) {
                    final categoriasDelTipo = _categoriasPorTipo[tipo] ?? [];
                    if (categoriasDelTipo.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            tipo.displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categoriasDelTipo.map((categoria) {
                            final isSelected = _categoriasSeleccionadas
                                .contains(categoria.idCategoria);
                            return FilterChip(
                              label: Text(categoria.nombre),
                              selected: isSelected,
                              onSelected: (selected) {
                                setStateDialog(() {
                                  if (selected) {
                                    _categoriasSeleccionadas
                                        .add(categoria.idCategoria);
                                  } else {
                                    _categoriasSeleccionadas
                                        .remove(categoria.idCategoria);
                                  }
                                });
                              },
                              selectedColor:
                                  const Color(0xFFF97316).withOpacity(0.2),
                              checkmarkColor: const Color(0xFFF97316),
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? const Color(0xFFF97316)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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

  /// Guarda las categorías asignadas al espacio
  Future<void> _guardarCategoriasDeEspacio() async {
    if (_espacioSeleccionado == null) return;

    // Verificar autenticación
    if (!AuthService().isAuthenticated) {
      _mostrarSnackBar(
        'Debes iniciar sesión como administrador para asignar categorías',
        esError: true,
      );
      
      // Opcional: redirigir al login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    try {
      print('Intentando guardar categorías para espacio: ${_espacioSeleccionado!.nombre}');
      print('Categorías seleccionadas: $_categoriasSeleccionadas');
      
      // Crear espacio actualizado con las nuevas categorías
      final espacioActualizado = Espacio(
        idEspacio: _espacioSeleccionado!.idEspacio,
        nombre: _espacioSeleccionado!.nombre,
        tipo: _espacioSeleccionado!.tipo,
        nivelOcupacion: _espacioSeleccionado!.nivelOcupacion,
        promedioCalificacion: _espacioSeleccionado!.promedioCalificacion,
        ubicacion: _espacioSeleccionado!.ubicacion,
        caracteristicas: _espacioSeleccionado!.caracteristicas,
        categoriaIds: _categoriasSeleccionadas.toList(),
      );

      print('Llamando a _espacioDAO.actualizar()...');
      await _espacioDAO.actualizar(espacioActualizado);
      print('Espacio actualizado exitosamente');

      setState(() {
        _espacioSeleccionado = espacioActualizado;
        final index = _espacios.indexWhere(
          (e) => e.idEspacio == espacioActualizado.idEspacio,
        );
        if (index != -1) {
          _espacios[index] = espacioActualizado;
        }
      });

      _mostrarSnackBar('Categorías asignadas correctamente');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetalleEspacioCategoriasScreen(espacio: espacioActualizado),
          ),
        );
      }
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
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFF97316),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargando categorías...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_errorMessage != null) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Error al cargar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF97316).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _cargarCategorias,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          'Reintentar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFF97316),
            backgroundColor: Colors.white,
            onRefresh: _cargarCategorias,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de asignación por espacio
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF97316).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.place,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Categorizar Espacios',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selecciona un espacio y asígnale categorías',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<Espacio?>(
                              value: _espacios.contains(_espacioSeleccionado) 
                                  ? _espacioSeleccionado 
                                  : null,
                              decoration: InputDecoration(
                                hintText: 'Selecciona un espacio',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFFF97316),
                                  size: 22,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                              items: _espacios.map((espacio) {
                                return DropdownMenuItem<Espacio?>(
                                  value: espacio,
                                  child: Text(
                                    espacio.nombre,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (espacio) {
                                setState(() {
                                  _dropdownInteractuado = true;
                                  _espacioSeleccionado = espacio;
                                });
                              },
                            ),
                          ),
                          if (_espacioSeleccionado != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_espacioSeleccionado!.categoriaIds.length} categoría(s) asignada(s)',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Botón Asignar Categorías
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _espacioSeleccionado != null
                            ? _asignarCategoriasAEspacio
                            : null,
                        icon: const Icon(Icons.edit_location_alt, size: 18),
                        label: const Text(
                          'Asignar Categorías',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[500],
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Botón Ver Detalles del Espacio
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _espacioSeleccionado != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalleEspacioCategoriasScreen(
                                      espacio: _espacioSeleccionado!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text(
                          'Ver Detalles del Espacio',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B5563),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[500],
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Botón para crear más categorías
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminCategoriasScreen(),
                            ),
                          );
                          _cargarCategorias();
                        },
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text(
                          'Crear Categorías',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

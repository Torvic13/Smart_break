import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../components/top_navbar.dart';
import '../components/bottom_navbar.dart';
import '../dao/dao_factory.dart';
import '../dao/auth_service.dart';
import '../models/espacio.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';
import '../models/nivel_ocupacion.dart';
import '../models/categoria_espacio.dart';
import 'detalle_espacio_screen.dart';
import 'crear_espacio_screen.dart';
import 'profile_screen.dart';
import 'admin_profile_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();

  List<Espacio> _espacios = [];
  List<Espacio> _filteredEspacios = [];
  List<CategoriaEspacio> _categorias = [];
  List<String> _selectedCategoryIds = [];

  bool _isLoading = true;

  // Centro del campus
  static const LatLng _campusCenter = LatLng(-12.084778, -76.971357);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Cargar espacios y categorías desde DAO (mock o backend)
  Future<void> _loadData() async {
  final daoFactory = Provider.of<DAOFactory>(context, listen: false);
  final espacioDAO = daoFactory.createEspacioDAO();
  final categoriaDAO = daoFactory.createCategoriaDAO();

  try {
    final espacios = await espacioDAO.obtenerTodos();
    final categorias = await categoriaDAO.obtenerTodas();

    // 👇 DEBUG: imprime lo que llega
    // (mira la consola de Android Studio / VS Code)
    // ************************************************
    print('>>> ESPACIOS RECIBIDOS: ${espacios.length}');
    for (final e in espacios) {
      print(' - ${e.nombre} @ ${e.ubicacion.latitud}, ${e.ubicacion.longitud}');
    }
    // ************************************************

    setState(() {
      _espacios = espacios;
      _filteredEspacios = espacios; // sin filtros por ahora
      _categorias = categorias;
      _isLoading = false;
    });
  } catch (e, st) {
    print('ERROR CARGANDO ESPACIOS: $e');
    print(st);
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _refrescarMapa() async {
    await _loadData();
  }

  Color _getOcupacionColor(NivelOcupacion nivel) {
    switch (nivel) {
      case NivelOcupacion.vacio:
        return Colors.green;
      case NivelOcupacion.bajo:
        return Colors.yellow[700]!;
      case NivelOcupacion.medio:
        return Colors.orange;
      case NivelOcupacion.alto:
        return Colors.red;
      case NivelOcupacion.lleno:
        return Colors.purple;
    }
  }

  // AGREGAR ESTA FUNCIÓN NUEVA
  NivelOcupacion _parseNivelOcupacion(String nivel) {
    switch (nivel) {
      case 'vacio': return NivelOcupacion.vacio;
      case 'bajo': return NivelOcupacion.bajo;
      case 'medio': return NivelOcupacion.medio;
      case 'alto': return NivelOcupacion.alto;
      case 'lleno': return NivelOcupacion.lleno;
      default: return NivelOcupacion.vacio;
    }
  }

  // 👇 CORREGIR ESTA FUNCIÓN - USAR Navigator.pushNamed
  void _showEspacioDetails(Espacio espacio) {
    Navigator.pushNamed(
      context,
      '/detalle-espacio',
      arguments: espacio,
    );
  }

  /// 🔥 Por ahora NO filtramos nada: siempre mostramos todos los espacios.
  void _applyFilters(List<String> selectedCategoryIds) {
    setState(() {
      _selectedCategoryIds = selectedCategoryIds;
      _filteredEspacios = _espacios; // ignorar filtros
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;

    return Scaffold(
      extendBody: true,
      appBar: TopNavBar(
        categorias: _categorias,
        onApplyFilters: _applyFilters, // aunque llame, no filtramos nada
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _campusCenter,
                    initialZoom: 18.0,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.smart_break',
                    ),

                    // 🔶 Marcadores: mostramos SIEMPRE todos los espacios cargados
                    MarkerLayer(
                      markers: _filteredEspacios.map((espacio) {
                        return Marker(
                          width: 60,
                          height: 60,
                          point: LatLng(
                            espacio.ubicacion.latitud,
                            espacio.ubicacion.longitud,
                          ),
                          child: GestureDetector(
                            onTap: () => _showEspacioDetails(espacio),
                            child: Icon(
                              Icons.location_on,
                              color: _getOcupacionColor(_parseNivelOcupacion(espacio.nivelOcupacion)), // CORREGIDO
                              size: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Leyenda de ocupación
                Positioned(
                  top: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ocupación',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLegendItem(
                              'Vacío', _getOcupacionColor(NivelOcupacion.vacio)),
                          _buildLegendItem(
                              'Bajo', _getOcupacionColor(NivelOcupacion.bajo)),
                          _buildLegendItem('Medio',
                              _getOcupacionColor(NivelOcupacion.medio)),
                          _buildLegendItem(
                              'Alto', _getOcupacionColor(NivelOcupacion.alto)),
                          _buildLegendItem(
                              'Lleno', _getOcupacionColor(NivelOcupacion.lleno)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

      // Botones flotantes
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (usuario is AdministradorSistema)
            FloatingActionButton(
              heroTag: 'crear',
              backgroundColor: Colors.green,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CrearEspacioScreen(usuarioActual: usuario),
                  ),
                );
                await _refrescarMapa();
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          if (usuario is AdministradorSistema) const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'centrar',
            backgroundColor: const Color(0xFFF97316),
            onPressed: () {
              _mapController.move(_campusCenter, 18.0);
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // ya estás en mapa
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/amigos');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/eventos');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/perfil');
              break;
          }
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
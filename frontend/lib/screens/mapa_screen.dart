import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/top_navbar.dart';
import '../components/bottom_navbar.dart';
import '../dao/dao_factory.dart';
import '../dao/auth_service.dart';
import '../models/espacio.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';
import '../models/categoria_espacio.dart';
import 'detalle_espacio_screen.dart';
import 'crear_espacio_screen.dart';
import 'profile_screen.dart';
import 'admin_profile_screen.dart';
import 'lista_espacios_screen.dart'; // 👈 agrega esta línea junto a los otros imports de screens

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
  bool _hasCheckedOnboarding = false;

  // Centro del campus
  static const LatLng _campusCenter = LatLng(-12.084778, -76.971357);

  @override
  void initState() {
    super.initState();
    _loadData();

    // Revisar onboarding después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });
  }

  /// Cargar espacios y categorías desde DAO (mock o backend)
  Future<void> _loadData() async {
    final daoFactory = Provider.of<DAOFactory>(context, listen: false);
    final espacioDAO = daoFactory.createEspacioDAO();
    final categoriaDAO = daoFactory.createCategoriaDAO();

    try {
      final espacios = await espacioDAO.obtenerTodos();
      final categorias = await categoriaDAO.obtenerTodas();

      // DEBUG
      print('>>> ESPACIOS RECIBIDOS: ${espacios.length}');
      for (final e in espacios) {
        print(' - ${e.nombre} @ ${e.ubicacion.latitud}, ${e.ubicacion.longitud}');
      }

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

  /// Onboarding que se muestra solo una vez por estudiante
  Future<void> _checkAndShowOnboarding() async {
    if (_hasCheckedOnboarding) return;
    _hasCheckedOnboarding = true;

    final usuario = AuthService().usuarioActual;

    // Solo mostramos onboarding a estudiantes (no al admin)
    if (usuario is! Estudiante) return;

    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenMapaOnboarding') ?? false;

    if (!hasSeen && mounted) {
      await prefs.setBool('hasSeenMapaOnboarding', true);
      _showOnboardingDialog();
    }
  }

  void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int currentPage = 0;
        const primaryOrange = Color(0xFFF97316);

        final pages = [
          (
            'Encuentra tu espacio ideal',
            'Explora el mapa del campus y descubre bibliotecas, salas de estudio, cafeterías y más.',
            Icons.map,
          ),
          (
            'Evita espacios llenos',
            'Revisa los niveles de ocupación para elegir el mejor lugar para estudiar o descansar.',
            Icons.people_alt,
          ),
          (
            'Califica y comenta',
            'Califica los espacios y deja comentarios para ayudar a otros estudiantes.',
            Icons.rate_review,
          ),
        ];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final (title, desc, icon) = pages[currentPage];

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 380,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Saltar',
                            style: TextStyle(color: primaryOrange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(icon, size: 72, color: primaryOrange),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => Container(
                            width: currentPage == index ? 20 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? primaryOrange
                                  : primaryOrange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentPage == pages.length - 1) {
                              Navigator.pop(context);
                            } else {
                              setStateDialog(() {
                                currentPage++;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            currentPage == pages.length - 1
                                ? 'Comenzar'
                                : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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

  void _showEspacioDetails(Espacio espacio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleEspacioScreen(espacio: espacio),
      ),
    );
  }

  /// Por ahora NO filtramos nada: siempre mostramos todos los espacios.
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
        onApplyFilters: _applyFilters,
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

                    // Marcadores: mostramos siempre todos los espacios cargados
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
                              color:
                                  _getOcupacionColor(espacio.nivelOcupacion),
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
                            'Vacío',
                            _getOcupacionColor(NivelOcupacion.vacio),
                          ),
                          _buildLegendItem(
                            'Bajo',
                            _getOcupacionColor(NivelOcupacion.bajo),
                          ),
                          _buildLegendItem(
                            'Medio',
                            _getOcupacionColor(NivelOcupacion.medio),
                          ),
                          _buildLegendItem(
                            'Alto',
                            _getOcupacionColor(NivelOcupacion.alto),
                          ),
                          _buildLegendItem(
                            'Lleno',
                            _getOcupacionColor(NivelOcupacion.lleno),
                          ),
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

          // Botón para volver a ver el onboarding
          FloatingActionButton(
            heroTag: 'showOnboarding',
            backgroundColor: Colors.blueAccent,
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('hasSeenMapaOnboarding');
              _showOnboardingDialog();
            },
            child: const Icon(Icons.help_outline, color: Colors.white),
          ),
          const SizedBox(height: 10),

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ListaEspaciosScreen(),
                ),
              );
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

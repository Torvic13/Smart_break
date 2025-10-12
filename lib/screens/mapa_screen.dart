import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../components/top_navbar.dart'; //
import '../components/bottom_navbar.dart';              // 👈 usa tu barra reusable
import '../dao/mock_dao_factory.dart';
import '../dao/auth_service.dart';
import '../models/espacio.dart';
import '../models/estudiante.dart';
import '../models/administrador_sistema.dart';
import '../models/usuario.dart';
import 'lista_espacios_screen.dart';
import 'detalle_espacio_screen.dart';
import 'crear_espacio_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  List<Espacio> _espacios = [];
  bool _isLoading = true;

  static const LatLng _campusCenter = LatLng(-12.084778, -76.971357);

  @override
  void initState() {
    super.initState();
    _loadEspacios();
  }

  Future<void> _loadEspacios() async {
    final daoFactory = Provider.of<MockDAOFactory>(context, listen: false);
    final espacioDAO = daoFactory.createEspacioDAO();

    try {
      final espacios = await espacioDAO.obtenerTodos();
      setState(() {
        _espacios = espacios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refrescarMapa() async {
    await _loadEspacios();
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

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;

    return Scaffold(
      extendBody: true, // para que la barra “glass” se superponga al mapa
      appBar: const TopNavBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _campusCenter,
                    initialZoom: 18.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.smart_break',
                    ),
                    MarkerLayer(
                      markers: _espacios.map((espacio) {
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
                              color: _getOcupacionColor(espacio.nivelOcupacion),
                              size: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Leyenda
                Positioned(
                  top: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ocupación',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          _buildLegendItem('Vacío', _getOcupacionColor(NivelOcupacion.vacio)),
                          _buildLegendItem('Bajo', _getOcupacionColor(NivelOcupacion.bajo)),
                          _buildLegendItem('Medio', _getOcupacionColor(NivelOcupacion.medio)),
                          _buildLegendItem('Alto', _getOcupacionColor(NivelOcupacion.alto)),
                          _buildLegendItem('Lleno', _getOcupacionColor(NivelOcupacion.lleno)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

      // FABs: crear (solo admin) + centrar
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
                    builder: (context) => CrearEspacioScreen(usuarioActual: usuario),
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

      // 👇 Barra reusable (índice 0 = Mapa)
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estás en Mapa
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
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

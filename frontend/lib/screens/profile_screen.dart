import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dao/dao_factory.dart';
import '../dao/auth_service.dart';
import '../models/estudiante.dart';
import '../models/usuario.dart';
import 'gestionar_categorias_screen.dart';
import 'welcome_screen.dart';
import '../components/bottom_navbar.dart'; // 👈 Barra inferior reusable

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Estudiante? _userProfile;
  bool _isLoading = true;
  bool _compartirUbicacion = true;
  bool _perfilPublico = false;
  bool _isSaveButtonVisible = false;

  final int _espaciosVisitados = 24;
  final int _favoritos = 8;
  final int _resenas = 12;

  final List<Map<String, dynamic>> _espaciosFavoritos = [
    {
      'nombre': 'Biblioteca - Sala 2',
      'visitas': 8,
      'color': const Color(0xFFFFEFE6),
      'icon': Icons.menu_book_rounded,
      'iconColor': const Color(0xFFF97316),
    },
    {
      'nombre': 'Jardín Central',
      'visitas': 5,
      'color': const Color(0xFFE6FFF2),
      'icon': Icons.flare_sharp,
      'iconColor': const Color(0xFF10B981),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
  final usuarioActual = AuthService().usuarioActual;

  if (!mounted) return;

  if (usuarioActual is Estudiante) {
    setState(() {
      _userProfile = usuarioActual;
      _compartirUbicacion = usuarioActual.ubicacionCompartida;
      _isLoading = false;
    });
    return;
  }

  // Si hay sesión pero no es Estudiante (ej. admin)
  if (usuarioActual != null) {
    setState(() {
      _isLoading = false;
    });
    return;
  }

  // Si no hay sesión (no debería pasar si entraste por login)
  setState(() {
    _isLoading = false;
  });
}

  void _removeFromFavorites(String nombreEspacio) {
    setState(() {
      _espaciosFavoritos.removeWhere((fav) => fav['nombre'] == nombreEspacio);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$nombreEspacio" se quitó de tus favoritos.')),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Habilitar edición de datos de perfil próximamente.'),
      ),
    );
  }

  void _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      AuthService().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    final daoFactory = Provider.of<DAOFactory>(context, listen: false);
    final usuarioDAO = daoFactory.createUsuarioDAO();

    if (_userProfile != null) {
      final updatedUser = Estudiante(
        idUsuario: _userProfile!.idUsuario,
        email: _userProfile!.email,
        passwordHash: _userProfile!.passwordHash,
        fechaCreacion: _userProfile!.fechaCreacion,
        estado: _userProfile!.estado,
        codigoAlumno: _userProfile!.codigoAlumno,
        nombreCompleto: _userProfile!.nombreCompleto,
        ubicacionCompartida: _compartirUbicacion,
        carrera: _userProfile!.carrera,
      );

      await usuarioDAO.actualizar(updatedUser);
      AuthService().actualizarUsuario(updatedUser);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSaveButtonVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios de configuración guardados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF97316)),
        ),
      );
    }

    if (_userProfile == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Perfil no encontrado.')),
      );
    }

    final initials = (_userProfile!.nombreCompleto.split(' ')
      ..retainWhere((s) => s.isNotEmpty))
        .map((s) => s[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: const Color(0xFFF97316),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentitySection(initials, _userProfile!, _userProfile!.carrera),
            const SizedBox(height: 32),
            _buildActivityMetrics(),
            const SizedBox(height: 32),
            _buildFavoriteSpaces(),
            const SizedBox(height: 32),
            _buildPrivacySettings(),

            if (AuthService().isAdmin) ...[
              const SizedBox(height: 32),
              _buildAdminSection(),
            ],

            if (_isSaveButtonVisible)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),

      // 👇 Barra inferior añadida (no altera estructura)
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/mapa');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/amigos');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/eventos');
              break;
            case 3:
              // Ya estás en perfil
              break;
          }
        },
      ),
    );
  }

  Widget _buildIdentitySection(String initials, Estudiante user, String carrera) {
    final displayInitials = initials.length > 2 ? initials.substring(0, 2) : initials;

    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF97316).withOpacity(0.8),
                  const Color(0xFFF97316),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayInitials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nombreCompleto,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            user.codigoAlumno,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            carrera,
            style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricCard('Espacios visitados', _espaciosVisitados),
        const SizedBox(width: 16),
        _buildMetricCard('Favoritos', _favoritos),
        const SizedBox(width: 16),
        _buildMetricCard('Reseñas', _resenas),
      ],
    );
  }

  Widget _buildMetricCard(String title, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF97316),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteSpaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Espacios Favoritos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _espaciosFavoritos.map((fav) {
            final nombre = fav['nombre'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildFavoriteSpaceCard(
                nombre,
                fav['visitas'] as int,
                fav['color'] as Color,
                fav['icon'] as IconData,
                fav['iconColor'] as Color,
                () => _removeFromFavorites(nombre),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFavoriteSpaceCard(
    String name,
    int visits,
    Color bgColor,
    IconData icon,
    Color iconColor,
    VoidCallback onTapStar,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(right: 12.0),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Visitado $visits veces',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTapStar,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.star, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración de Privacidad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        _buildToggleCard(
          'Compartir ubicación',
          Icons.location_on_outlined,
          _compartirUbicacion,
          (bool newValue) {
            setState(() {
              _compartirUbicacion = newValue;
              _isSaveButtonVisible = true;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildToggleCard(
          'Perfil público',
          Icons.circle,
          _perfilPublico,
          (bool newValue) {
            setState(() {
              _perfilPublico = newValue;
              _isSaveButtonVisible = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Administración',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GestionarCategoriasScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category, color: Color(0xFFF97316), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestionar Categorías',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Administrar tipos de espacio y niveles de ruido',
                          style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF718096)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    String title,
    IconData leadingIcon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(leadingIcon, size: 20, color: const Color(0xFF4A5568)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF97316),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E0),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../dao/auth_service.dart';
import '../models/administrador_sistema.dart';
import 'gestionar_categorias_screen.dart';
import 'welcome_screen.dart';
import 'crear_espacio_screen.dart'; // 

/// Pantalla de perfil para administradores del sistema
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  AdministradorSistema? _adminProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    final usuarioActual = AuthService().usuarioActual;

    if (usuarioActual != null && usuarioActual is AdministradorSistema && mounted) {
      setState(() {
        _adminProfile = usuarioActual;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
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

    if (_adminProfile == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Perfil de administrador no encontrado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de identidad del administrador
            _buildAdminIdentitySection(),
            const SizedBox(height: 32),
            
            // Opciones de administración
            const Text(
              'Opciones de Administración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tarjeta de Gestionar Categorías
            _buildAdminOptionCard(
              title: 'Gestionar Categorías',
              subtitle: 'Administrar tipos de espacio y niveles de ruido',
              icon: Icons.category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GestionarCategoriasScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // 🔹 Tarjeta de Gestionar Espacios → CrearEspacioScreen
            _buildAdminOptionCard(
              title: 'Gestionar Espacios',
              subtitle: 'Crear, editar y eliminar espacios',
              icon: Icons.place,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearEspacioScreen(
                      usuarioActual: _adminProfile!, // 
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // Tarjeta de Gestionar Usuarios
            _buildAdminOptionCard(
              title: 'Gestionar Usuarios',
              subtitle: 'Ver y administrar usuarios del sistema',
              icon: Icons.people,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad próximamente'),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Botón de cerrar sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cerrarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminIdentitySection() {
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
                  const Color(0xFFF97316)
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
            child: const Center(
              child: Icon(
                Icons.admin_panel_settings,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Administrador del Sistema',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            _adminProfile!.email,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ROL: ADMIN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF97316),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                child: Icon(
                  icon,
                  color: const Color(0xFFF97316),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF718096),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dao/dao_factory.dart';
import '../dao/http_usuario_dao.dart';
import '../dao/auth_service.dart';
import '../models/estudiante.dart';
import '../components/bottom_navbar.dart';

class AmigosScreen extends StatefulWidget {
  const AmigosScreen({super.key});

  @override
  State<AmigosScreen> createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  List<Estudiante> _amigos = [];
  bool _isLoading = true;
  bool _ubicacionCompartida = false;
  final TextEditingController _codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final usuario = AuthService().usuarioActual;
    if (usuario is Estudiante) {
      _ubicacionCompartida = usuario.ubicacionCompartida;
    }
    _cargarAmigos();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _cargarAmigos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usuarioActual = AuthService().usuarioActual;
      if (usuarioActual == null) {
        throw Exception('No hay usuario autenticado');
      }

      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final usuarioDAO = daoFactory.createUsuarioDAO() as HttpUsuarioDAO;
      
      final amigos = await usuarioDAO.obtenerAmigos(usuarioActual.idUsuario);

      if (mounted) {
        setState(() {
          _amigos = amigos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar amigos: $e')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoAgregarAmigo() async {
    _codigoController.clear();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Amigo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el código de alumno de tu amigo',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: 'Código de Alumno',
                hintText: 'Ej: A01234567',
                prefixIcon: const Icon(Icons.person_search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _buscarYAgregarAmigo(_codigoController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
            ),
            child: const Text('Buscar y Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _buscarYAgregarAmigo(String codigoAlumno) async {
    if (codigoAlumno.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un código de alumno válido')),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final usuarioActual = AuthService().usuarioActual;
      if (usuarioActual == null) {
        throw Exception('No hay usuario autenticado');
      }

      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final usuarioDAO = daoFactory.createUsuarioDAO() as HttpUsuarioDAO;

      // Buscar usuario por código
      final amigo = await usuarioDAO.buscarPorCodigo(codigoAlumno);

      if (!mounted) return;

      // Cerrar indicador de carga
      Navigator.pop(context);

      if (amigo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró ningún usuario con ese código'),
          ),
        );
        return;
      }

      // Verificar que no se agregue a sí mismo
      if (amigo.idUsuario == usuarioActual.idUsuario) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes agregarte a ti mismo como amigo'),
          ),
        );
        return;
      }

      // Confirmar antes de agregar
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Deseas agregar a este usuario como amigo?'),
              const SizedBox(height: 12),
              Card(
                color: const Color(0xFFFFF7ED),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFF97316),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              amigo.nombreCompleto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              amigo.codigoAlumno,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              amigo.carrera,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              child: const Text('Agregar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      // Agregar amigo
      await usuarioDAO.agregarAmigo(usuarioActual.idUsuario, amigo.idUsuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${amigo.nombreCompleto} se agregó a tus amigos'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar lista de amigos
      _cargarAmigos();
    } catch (e) {
      if (!mounted) return;

      // Cerrar indicador de carga si está abierto
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Amigos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF97316),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _mostrarDialogoAgregarAmigo,
            tooltip: 'Agregar amigo',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildControlUbicacion(),
                Expanded(
                  child: _amigos.isEmpty
                      ? _buildEmptyState()
                      : _buildListaAmigos(),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/mapa');
              break;
            case 1:
              // Ya estás en amigos
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
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarAmigo,
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes amigos agregados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega amigos usando su código de alumno',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _mostrarDialogoAgregarAmigo,
              icon: const Icon(Icons.person_add),
              label: const Text('Agregar Amigo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaAmigos() {
    return RefreshIndicator(
      onRefresh: _cargarAmigos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _amigos.length,
        itemBuilder: (context, index) {
          final amigo = _amigos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFF97316),
                child: Text(
                  amigo.nombreCompleto.isNotEmpty
                      ? amigo.nombreCompleto[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                amigo.nombreCompleto,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.badge,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        amigo.codigoAlumno,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          amigo.carrera,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (amigo.ubicacionCompartida)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Ubicación',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Icon(Icons.location_off, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                if (amigo.ubicacionCompartida) {
                  // Navegar al mapa con la ubicación del amigo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ver ubicación de ${amigo.nombreCompleto}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${amigo.nombreCompleto} no comparte su ubicación'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlUbicacion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SwitchListTile(
          title: const Text(
            'Compartir mi ubicación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            _ubicacionCompartida 
              ? '🟢 Tus amigos pueden ver tu ubicación' 
              : '🔴 Tu ubicación está oculta',
            style: TextStyle(
              fontSize: 13,
              color: _ubicacionCompartida ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          value: _ubicacionCompartida,
          activeColor: const Color(0xFFF97316),
          onChanged: (value) async {
            try {
              final usuario = AuthService().usuarioActual;
              if (usuario == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debes iniciar sesión')),
                );
                return;
              }
              
              setState(() => _ubicacionCompartida = value);
              
              final daoFactory = Provider.of<DAOFactory>(context, listen: false);
              final usuarioDAO = daoFactory.createUsuarioDAO() as HttpUsuarioDAO;
              
              await usuarioDAO.actualizarUbicacionCompartida(
                usuario.idUsuario, 
                value
              );
              
              // Actualizar en AuthService
              if (usuario is Estudiante) {
                final actualizado = Estudiante(
                  idUsuario: usuario.idUsuario,
                  email: usuario.email,
                  passwordHash: usuario.passwordHash,
                  fechaCreacion: usuario.fechaCreacion,
                  estado: usuario.estado,
                  codigoAlumno: usuario.codigoAlumno,
                  nombreCompleto: usuario.nombreCompleto,
                  ubicacionCompartida: value,
                  carrera: usuario.carrera,
                  amigosIds: usuario.amigosIds,
                );
                AuthService().actualizarUsuario(actualizado);
              }
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value 
                      ? '✅ Ubicación compartida con amigos' 
                      : '🔒 Ubicación oculta'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: value ? Colors.green : Colors.grey,
                  ),
                );
              }
            } catch (e) {
              setState(() => _ubicacionCompartida = !value);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

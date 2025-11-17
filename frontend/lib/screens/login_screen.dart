import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dao/dao_factory.dart';
import '../dao/auth_service.dart';
import '../models/administrador_sistema.dart';  // 👈 importa el modelo admin
import 'mapa_screen.dart';
import 'register_screen.dart';
import 'admin_profile_screen.dart';             // 👈 importa la pantalla admin

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final daoFactory = Provider.of<DAOFactory>(context, listen: false);
    final authDao = daoFactory.createAuthDAO();

    final usuario = await authDao.iniciarSesion(
      email: _emailController.text,
      pass: _passwordController.text,
    );

    if (!mounted) return;

    if (usuario == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Credenciales inválidas';
      });
      return;
    }

    // Guardamos usuario en AuthService (y eventualmente el token)
    AuthService().setUsuario(usuario);

    // Navegación según tipo
    if (usuario is AdministradorSistema) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminProfileScreen(),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MapaScreen(),
        ),
        (route) => false,
      );
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF97316); 
    const lightOrangeBackground = Color.fromARGB(255, 246, 221, 186); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryOrange), 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.white, 
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- ICONO DEL MAPA (LOGO) ---
                      Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: lightOrangeBackground, 
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(bottom: 32.0),
                          child: const Icon(
                            Icons.map, 
                            size: 100,
                            color: primaryOrange,
                          ),
                        ),
                      ),
                      // --- FIN: ICONO DEL MAPA (LOGO) ---
                      Text(
                        '¡Bienvenido de nuevo!',
                        style: TextStyle(
                          color: Colors.grey.shade800, 
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email, color: primaryOrange), 
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su correo';
                                }
                                if (!value.contains('@')) {
                                  return 'Ingrese un correo válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock, color: primaryOrange), 
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange, 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: primaryOrange, 
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes una cuenta? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                color: primaryOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

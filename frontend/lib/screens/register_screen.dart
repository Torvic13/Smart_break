import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dao/dao_factory.dart';
import 'login_screen.dart';

// Lista de carreras universitarias
const List<String> _carreras = [
  'Administración',
  'Arquitectura',
  'Comunicación',
  'Contabilidad y Finanzas',
  'Derecho',
  'Economía',
  'Ingeniería Ambiental',
  'Ingeniería Civil',
  'Ingeniería Industrial',
  'Ingeniería Mecatrónica',
  'Ingeniería de Sistemas',
  'Marketing',
  'Negocios Internacionales',
  'Psicología',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Nueva variable de estado para la carrera
  String? _carreraSeleccionada; 

  bool _isLoading = false;
  bool _aceptaTerminos = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validamos el formulario, incluyendo el Dropdown
    if (!_formKey.currentState!.validate()) return;
    
    if (!_aceptaTerminos) {
      setState(() {
        _errorMessage = 'Debes aceptar los Términos y Condiciones para continuar';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final daoFactory = Provider.of<DAOFactory>(context, listen: false);
      final authDao = daoFactory.createAuthDAO();

      final userData = {
        'nombreCompleto': _nombreController.text,
        'codigoAlumno': _codigoController.text,
        'carrera': _carreraSeleccionada,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      await authDao.crearCuenta(userData);


      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Por favor inicia sesión.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al crear la cuenta: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF97316);

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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white, 
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        color: Colors.black87, 
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
                          // --- Campo Nombre Completo ---
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: Icon(Icons.person, color: primaryOrange),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su nombre completo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // --- Campo Código de Alumno ---
                          TextFormField(
                            controller: _codigoController,
                            decoration: const InputDecoration(
                              labelText: 'Código de alumno',
                              prefixIcon: Icon(Icons.badge, color: primaryOrange),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su código de alumno';
                              }
                              if (!RegExp(r'^\d+$').hasMatch(value)) {
                                return 'El código solo debe contener números';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // --- NUEVO: Campo Carrera (Lista Desplegable) ---
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Carrera',
                              prefixIcon: Icon(Icons.school, color: primaryOrange),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            value: _carreraSeleccionada,
                            hint: const Text('Seleccione su carrera'),
                            isExpanded: true,
                            items: _carreras.map((String carrera) {
                              return DropdownMenuItem<String>(
                                value: carrera,
                                child: Text(carrera),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _carreraSeleccionada = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Debe seleccionar una carrera';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // --- Campo Correo Electrónico ---
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email, color: primaryOrange),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su correo';
                              }
                              RegExp emailRegex = RegExp(r'^\d{8}@[^.]+\.[^.]+\.[^.]+\.[^.]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Ingrese un correo universitario válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // --- Campo Contraseña ---
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Mínimo 8 caracteres',
                              prefixIcon: Icon(Icons.lock, color: primaryOrange),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su contraseña';
                              }
                              if (value.length < 8) {
                                return 'La contraseña debe tener al menos 8 caracteres';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Debe incluir al menos una mayúscula';
                              }
                              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                return 'Debe incluir al menos un carácter especial';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // --- Campo Confirmar Contraseña ---
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              hintText: 'Repite tu contraseña',
                              prefixIcon: Icon(Icons.lock_outline, color: primaryOrange),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirme su contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // --- Checkbox Términos y Condiciones ---
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _aceptaTerminos,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _aceptaTerminos = value ?? false;
                                    });
                                  },
                                  activeColor: primaryOrange,
                                ),
                                const Text('Acepto los '),
                                Text(
                                  'Términos y Condiciones',
                                  style: const TextStyle(
                                    color: primaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(), 
                              ],
                            ),
                          ),
                          // --- Mensaje de Error ---
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
                    // --- Botón Registrarse ---
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white), 
                              ),
                            )
                          : const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    // --- Enlace Inicia Sesión ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          ),
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
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
      )
    );
  }
}
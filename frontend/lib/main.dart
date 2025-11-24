import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// DAO Factory (usa backend para auth y espacios)
import 'dao/dao_factory.dart';
import 'dao/http_dao_factory.dart'; // Asegúrate de que este archivo exista y esté correcto

// Servicios
import 'dao/auth_service.dart';

// Pantallas
import 'screens/welcome_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_profile_screen.dart';

// 💡 IP para Emulador de Android (Apuntando al puerto 4000 de tu backend)
// Ajusta si estás usando un dispositivo físico o iOS.
const String kBaseUrl = 'http://10.0.2.2:4000/api'; 
// Si usas un dispositivo físico o iOS, usa tu IP de red: 'http://192.168.x.x:4000/api'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Cargar sesión guardada (si existe un token en SharedPreferences)
  await AuthService().cargarSesion();

  runApp(const SmartBreakApp());
}

class SmartBreakApp extends StatelessWidget {
  const SmartBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔹 AuthService como ChangeNotifier
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),

        // 🔹 DAOFactory usando backend
        Provider<DAOFactory>(
          // Llama al constructor con el parámetro requerido 'baseUrl'
          create: (_) => HttpDAOFactory(baseUrl: kBaseUrl), 
        ),
      ],
      child: MaterialApp(
        title: 'SmartBreak',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF97316),
          ),
          useMaterial3: true,

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF97316),
            foregroundColor: Colors.white,
            elevation: 0,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/mapa': (context) => const MapaScreen(),
          '/perfil': (context) => const UserProfileScreen(),
          '/admin': (context) => const AdminProfileScreen(),
        },
      ),
    );
  }
}
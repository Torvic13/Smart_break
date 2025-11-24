import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// DAO Factory (usa backend para auth y espacios)
import 'dao/dao_factory.dart';
import 'dao/http_dao_factory.dart';

// Servicios
import 'dao/auth_service.dart';

// Pantallas
import 'screens/welcome_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_profile_screen.dart';
import 'screens/amigos_screen.dart';

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
          create: (_) => HttpDAOFactory(),
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
          '/amigos': (context) => const AmigosScreen(),
        },
      ),
    );
  }
}

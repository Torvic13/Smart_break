import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dao/dao_factory.dart';
import 'dao/http_dao_factory.dart';        // 👈 NUEVO: factory que usa el backend
import 'screens/welcome_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/profile_screen.dart';
import 'dao/auth_service.dart';           // ya lo tenías como package, lo dejo relativo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().cargarSesion(); // 🔹 Carga el usuario si hay sesión guardada
  runApp(const SmartBreakApp());
}

class SmartBreakApp extends StatelessWidget {
  const SmartBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 👇 AuthService como ChangeNotifier (opcional pero útil)
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),

        // 👇 Aquí elegimos la implementación REAL de los DAOs
        Provider<DAOFactory>(
          create: (_) => HttpDAOFactory(), // Usa backend para AuthDAO
        ),
      ],
      child: MaterialApp(
        title: 'Smart Break',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF772D),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF772D),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF772D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/mapa': (context) => const MapaScreen(),
          '/perfil': (context) => const UserProfileScreen(),
        },
      ),
    );
  }
}

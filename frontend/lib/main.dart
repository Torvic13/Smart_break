// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// DAO Factory
import 'dao/dao_factory.dart';
import 'dao/dao_factory_impl.dart';

// Servicios
import 'dao/auth_service.dart';
import 'dao/auth_dao.dart';
import 'dao/http_auth_dao.dart';

// Pantallas
import 'screens/welcome_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_profile_screen.dart';
import 'screens/mis_calificaciones_screen.dart';
import 'screens/lista_espacios_screen.dart';
import 'screens/detalle_espacio_screen.dart';

import 'models/espacio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().cargarSesion();
  runApp(const SmartBreakApp());
}

class SmartBreakApp extends StatelessWidget {
  const SmartBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),

        // AuthDAO sin token
        Provider<AuthDAO>(
          create: (_) => HttpAuthDAO(
            baseUrl: 'http://10.0.2.2:4000/api/v1',
          ),
        ),

        // DAOFactory (no usa authToken)
        Provider<DAOFactory>(
          create: (_) => DAOFactoryImpl(),
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
        ),
        initialRoute: AppRoutes.welcome,
        routes: {
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.mapa: (context) => const MapaScreen(),
          AppRoutes.perfil: (context) => const UserProfileScreen(),
          AppRoutes.admin: (context) => const AdminProfileScreen(),
          AppRoutes.espacios: (context) => ListaEspaciosScreen(),
          AppRoutes.misCalificaciones: (context) =>
              Consumer<AuthService>(builder: (context, authService, child) {
            if (authService.usuarioActual == null ||
                authService.token.isEmpty) {
              Future.microtask(() {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.welcome);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return MisCalificacionesScreen(
              userId: authService.usuarioActual!.idUsuario,
              authToken: authService.token,
            );
          }),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.detalleEspacio) {
            final espacio = settings.arguments as Espacio;
            return MaterialPageRoute(
              builder: (_) => DetalleEspacioScreen(espacio: espacio),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AppRoutes {
  static const String welcome = '/';
  static const String mapa = '/mapa';
  static const String perfil = '/perfil';
  static const String admin = '/admin';
  static const String misCalificaciones = '/mis-calificaciones';
  static const String espacios = '/espacios';
  static const String detalleEspacio = '/detalle-espacio';
}

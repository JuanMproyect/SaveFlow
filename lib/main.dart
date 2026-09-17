import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transactions/transaction_list_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'ux/theme.dart';
import 'ux/widgets/nav_bar.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SaveFlowApp());
}

final ValueNotifier<ThemeMode> modoTemaGlobal = ValueNotifier(ThemeMode.light);

class SaveFlowApp extends StatelessWidget {
  const SaveFlowApp({super.key});

  @override
  Widget build(BuildContext contexto) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoTemaGlobal,
      builder: (contexto, modoActual, _) {
        return MaterialApp(
          title: 'SaveFlow',
          debugShowCheckedModeBanner: false,
          theme: TemaSaveFlow.temaClaro,
          darkTheme: TemaSaveFlow.temaOscuro,
          themeMode: modoActual,
          home: const PantallaCarga(),
        );
      },
    );
  }
}

// Decide si mostrar Login o la Navegación Principal según el estado de sesión
class PantallaInicial extends StatelessWidget {
  const PantallaInicial({super.key});

  @override
  Widget build(BuildContext contexto) {
    final servicioAuth = ServicioAutenticacion();

    return StreamBuilder<User?>(
      stream: servicioAuth.estadoAutenticacion,
      builder: (contexto, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const PantallaNavegacionPrincipal();
        }

        return const PantallaInicioSesion();
      },
    );
  }
}

// Contenedor con la barra de navegación inferior y las 5 pantallas principales
class PantallaNavegacionPrincipal extends StatefulWidget {
  const PantallaNavegacionPrincipal({super.key});

  @override
  State<PantallaNavegacionPrincipal> createState() =>
      _EstadoPantallaNavegacionPrincipal();
}

class _EstadoPantallaNavegacionPrincipal
    extends State<PantallaNavegacionPrincipal> {
  int _indiceSeleccionado = 0;

  List<Widget> get _pantallas => [
    PantallaDashboard(
      alTocarVerTodas: () => setState(() => _indiceSeleccionado = 1),
    ),
    const PantallaListaTransacciones(),
    const PantallaMetas(),
    const PantallaChatbot(),
    const PantallaPerfil(),
  ];

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      body: _pantallas[_indiceSeleccionado],
      bottomNavigationBar: BarraNavegacionInferior(
        indiceSeleccionado: _indiceSeleccionado,
        alCambiarIndice: (indice) =>
            setState(() => _indiceSeleccionado = indice),
      ),
    );
  }
}

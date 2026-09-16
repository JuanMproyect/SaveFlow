import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../ux/theme.dart';
import '../../ux/widgets/custom_button.dart';
import '../../ux/widgets/custom_input.dart';
import 'register_screen.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _EstadoPantallaInicioSesion();
}

class _EstadoPantallaInicioSesion extends State<PantallaInicioSesion> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();

  final ServicioAutenticacion _servicioAuth = ServicioAutenticacion();

  bool _cargando = false;
  String? _mensajeError;

  Future<void> _manejarInicioSesion() async {
    if (!_llaveFormulario.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    final error = await _servicioAuth.iniciarSesion(
      correo: _controladorCorreo.text.trim(),
      contrasena: _controladorContrasena.text.trim(),
    );

    if (!mounted) return;

    setState(() => _cargando = false);

    if (error != null && mounted) {
      setState(() => _mensajeError = error);
    }
  }

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // ── Encabezado con ícono ───────────────────────────
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            TemaSaveFlow.verdeEsmeralda,
                            TemaSaveFlow.azulMarino,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: TemaSaveFlow.verdeEsmeralda.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Bienvenido de vuelta',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar con tus finanzas',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),

                  // ── Formulario ──────────────────────────────────────
                  Form(
                    key: _llaveFormulario,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CampoTexto(
                          controlador: _controladorCorreo,
                          etiqueta: 'Correo electrónico',
                          tipoTeclado: TextInputType.emailAddress,
                          validador: (valor) =>
                              valor == null || !valor.contains('@')
                              ? 'Correo inválido'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        CampoTexto(
                          controlador: _controladorContrasena,
                          etiqueta: 'Contraseña',
                          ocultarTexto: true,
                          validador: (valor) => valor == null || valor.isEmpty
                              ? 'Ingresa tu contraseña'
                              : null,
                        ),

                        if (_mensajeError != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _mensajeError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),
                        BotonPrincipal(
                          cargando: _cargando,
                          texto: 'Entrar',
                          alPresionar: _manejarInicioSesion,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          contexto,
                          MaterialPageRoute(
                            builder: (contexto) => const PantallaRegistro(),
                          ),
                        ),
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: TemaSaveFlow.verdeEsmeralda,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

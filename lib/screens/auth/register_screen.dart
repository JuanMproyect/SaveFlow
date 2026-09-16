import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../ux/theme.dart';
import '../../ux/widgets/custom_button.dart';
import '../../ux/widgets/custom_input.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorNombre = TextEditingController();

  final ServicioAutenticacion _servicioAuth = ServicioAutenticacion();

  String _monedaSeleccionada = 'HNL';
  bool _cargando = false;
  String? _mensajeError;

  final List<String> _monedasDisponibles = ['HNL', 'USD', 'EUR'];

  Future<void> _manejarRegistro() async {
    if (!_llaveFormulario.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    final error = await _servicioAuth.registrarUsuario(
      correo: _controladorCorreo.text.trim(),
      contrasena: _controladorContrasena.text.trim(),
      nombreVisible: _controladorNombre.text.trim(),
      monedaBase: _monedaSeleccionada,
    );

    if (!mounted) return;

    setState(() => _cargando = false);

    if (error != null && mounted) {
      setState(() => _mensajeError = error);
    } else if (mounted) {
      Navigator.popUntil(context, (ruta) => ruta.isFirst);
    }
  }

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _controladorNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior con botón atrás ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(contexto),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Encabezado ────────────────────────────────
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  TemaSaveFlow.verdeEsmeralda,
                                  TemaSaveFlow.azulMarino,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: TemaSaveFlow.verdeEsmeralda
                                      .withOpacity(0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Crea tu cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Empieza a controlar tus finanzas hoy mismo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Formulario ────────────────────────────────
                        Form(
                          key: _llaveFormulario,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CampoTexto(
                                controlador: _controladorNombre,
                                etiqueta: 'Nombre',
                                validador: (valor) =>
                                    valor == null || valor.isEmpty
                                    ? 'Ingresa tu nombre'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              CampoTexto(
                                controlador: _controladorCorreo,
                                etiqueta: 'Correo electrónico',
                                tipoTeclado: TextInputType.emailAddress,
                                validador: (valor) =>
                                    valor == null || !valor.contains('@')
                                    ? 'Correo inválido'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              CampoTexto(
                                controlador: _controladorContrasena,
                                etiqueta: 'Contraseña',
                                ocultarTexto: true,
                                validador: (valor) =>
                                    valor == null || valor.length < 6
                                    ? 'Mínimo 6 caracteres'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Selector de moneda con el mismo estilo visual
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _monedaSeleccionada,
                                  decoration: const InputDecoration(
                                    labelText: 'Moneda base',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  items: _monedasDisponibles
                                      .map(
                                        (moneda) => DropdownMenuItem(
                                          value: moneda,
                                          child: Text(moneda),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (valor) => setState(
                                    () => _monedaSeleccionada = valor!,
                                  ),
                                ),
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

                              const SizedBox(height: 26),
                              BotonPrincipal(
                                cargando: _cargando,
                                texto: 'Registrarme',
                                alPresionar: _manejarRegistro,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

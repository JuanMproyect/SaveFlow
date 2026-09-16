import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_message_model.dart';
import '../../services/gemini_service.dart';
import '../../services/auth_service.dart';

class PantallaChatbot extends StatefulWidget {
  const PantallaChatbot({super.key});

  @override
  State<PantallaChatbot> createState() => _EstadoPantallaChatbot();
}

class _EstadoPantallaChatbot extends State<PantallaChatbot> {
  final _controladorMensaje = TextEditingController();
  final _controladorScroll = ScrollController();

  final ServicioGemini _servicioGemini = ServicioGemini();
  final ServicioAutenticacion _servicioAuth = ServicioAutenticacion();

  final List<MensajeChatModelo> _mensajes = [];
  bool _escribiendo = false; // true mientras el bot está "pensando"

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida inicial, solo visual, no se envía a Gemini
    _mensajes.add(MensajeChatModelo(
      texto: '¡Hola! Soy tu asistente financiero de SaveFlow. '
          'Pregúntame sobre tus gastos, ahorros o metas.',
      esUsuario: false,
      fecha: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controladorMensaje.dispose();
    _controladorScroll.dispose();
    super.dispose();
  }

  void _desplazarAbajo() {
    // Espera un frame para que el nuevo mensaje ya esté renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controladorScroll.hasClients) {
        _controladorScroll.animateTo(
          _controladorScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarPregunta() async {
    final pregunta = _controladorMensaje.text.trim();
    if (pregunta.isEmpty || _escribiendo) return;

    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      _mensajes.add(MensajeChatModelo(
        texto: pregunta,
        esUsuario: true,
        fecha: DateTime.now(),
      ));
      _escribiendo = true;
      _controladorMensaje.clear();
    });
    _desplazarAbajo();

    try {
      final usuario = await _servicioAuth.obtenerDatosUsuario(idUsuario);
      final monedaBase = usuario?.monedaBase ?? 'HNL';

      final contexto = await _servicioGemini.construirContexto(idUsuario);
      final respuesta = await _servicioGemini.enviarConsulta(
        pregunta: pregunta,
        contexto: contexto,
        monedaBase: monedaBase,
      );

      if (!mounted) return;

      setState(() {
        _mensajes.add(MensajeChatModelo(
          texto: respuesta,
          esUsuario: false,
          fecha: DateTime.now(),
        ));
        _escribiendo = false;
      });
      _desplazarAbajo();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _mensajes.add(MensajeChatModelo(
          texto: 'Ocurrió un error al procesar tu pregunta. Intenta de nuevo.',
          esUsuario: false,
          fecha: DateTime.now(),
        ));
        _escribiendo = false;
      });
      _desplazarAbajo();
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente financiero')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controladorScroll,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_escribiendo ? 1 : 0),
              itemBuilder: (contexto, indice) {
                // Último ítem = indicador de "escribiendo..." si está activo
                if (indice == _mensajes.length) {
                  return const _BurbujaEscribiendo();
                }
                return _BurbujaMensaje(mensaje: _mensajes[indice]);
              },
            ),
          ),
          _CampoEntradaMensaje(
            controlador: _controladorMensaje,
            habilitado: !_escribiendo,
            alEnviar: _enviarPregunta,
          ),
        ],
      ),
    );
  }
}

// ── Burbuja individual de mensaje (usuario o bot) ──────────────────────────
class _BurbujaMensaje extends StatelessWidget {
  final MensajeChatModelo mensaje;

  const _BurbujaMensaje({required this.mensaje});

  @override
  Widget build(BuildContext contexto) {
    final esUsuario = mensaje.esUsuario;
    final colorPrimario = Theme.of(contexto).colorScheme.primary;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(contexto).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esUsuario ? colorPrimario : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 16),
          ),
        ),
        child: Text(
          mensaje.texto,
          style: TextStyle(
            color: esUsuario ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ── Indicador de "el bot está escribiendo" ─────────────────────────────────
class _BurbujaEscribiendo extends StatelessWidget {
  const _BurbujaEscribiendo();

  @override
  Widget build(BuildContext contexto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

// ── Campo de texto inferior para escribir la pregunta ──────────────────────
class _CampoEntradaMensaje extends StatelessWidget {
  final TextEditingController controlador;
  final bool habilitado;
  final VoidCallback alEnviar;

  const _CampoEntradaMensaje({
    required this.controlador,
    required this.habilitado,
    required this.alEnviar,
  });

  @override
  Widget build(BuildContext contexto) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controlador,
                enabled: habilitado,
                decoration: InputDecoration(
                  hintText: 'Pregunta sobre tus finanzas...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => alEnviar(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: Theme.of(contexto).colorScheme.primary,
              onPressed: habilitado ? alEnviar : null,
            ),
          ],
        ),
      ),
    );
  }
}
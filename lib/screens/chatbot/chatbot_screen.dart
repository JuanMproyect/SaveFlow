import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_message_model.dart';
import '../../services/gemini_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_history_service.dart';

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
  final ServicioHistorialChat _servicioHistorial = ServicioHistorialChat();

  bool _escribiendo = false;

  @override
  void dispose() {
    _controladorMensaje.dispose();
    _controladorScroll.dispose();
    super.dispose();
  }

  void _desplazarAbajo() {
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

  Future<void> _enviarPregunta(String idUsuario) async {
    final pregunta = _controladorMensaje.text.trim();
    if (pregunta.isEmpty || _escribiendo) return;

    _controladorMensaje.clear();
    setState(() => _escribiendo = true);

    // Guarda el mensaje del usuario en Firestore (el StreamBuilder lo mostrará solo)
    await _servicioHistorial.guardarMensaje(
      MensajeChatModelo(
        idMensaje: '',
        idUsuario: idUsuario,
        texto: pregunta,
        esUsuario: true,
        fecha: DateTime.now(),
      ),
    );
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

      await _servicioHistorial.guardarMensaje(
        MensajeChatModelo(
          idMensaje: '',
          idUsuario: idUsuario,
          texto: respuesta,
          esUsuario: false,
          fecha: DateTime.now(),
        ),
      );
    } catch (error) {
      await _servicioHistorial.guardarMensaje(
        MensajeChatModelo(
          idMensaje: '',
          idUsuario: idUsuario,
          texto: 'Ocurrió un error al procesar tu pregunta. Intenta de nuevo.',
          esUsuario: false,
          fecha: DateTime.now(),
        ),
      );
    } finally {
      if (mounted) setState(() => _escribiendo = false);
      _desplazarAbajo();
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Asistente financiero')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MensajeChatModelo>>(
              stream: _servicioHistorial.obtenerHistorial(idUsuario),
              builder: (contexto, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensajes = snapshot.data ?? [];

                // Mensaje de bienvenida solo si no hay historial aún
                if (mensajes.isEmpty && !_escribiendo) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        '¡Hola! Soy tu asistente financiero de SaveFlow.\n'
                        'Pregúntame sobre tus gastos, ahorros o metas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                _desplazarAbajo();

                return ListView.builder(
                  controller: _controladorScroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length + (_escribiendo ? 1 : 0),
                  itemBuilder: (contexto, indice) {
                    if (indice == mensajes.length) {
                      return const _BurbujaEscribiendo();
                    }
                    return _BurbujaMensaje(mensaje: mensajes[indice]);
                  },
                );
              },
            ),
          ),
          _CampoEntradaMensaje(
            controlador: _controladorMensaje,
            habilitado: !_escribiendo,
            alEnviar: () => _enviarPregunta(idUsuario),
          ),
        ],
      ),
    );
  }
}

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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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

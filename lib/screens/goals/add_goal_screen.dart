import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/goal_model.dart';
import '../../services/goal_service.dart';
import '../../ux/widgets/custom_button.dart';
import '../../ux/widgets/custom_input.dart';

class PantallaAgregarMeta extends StatefulWidget {
  const PantallaAgregarMeta({super.key});

  @override
  State<PantallaAgregarMeta> createState() => _EstadoPantallaAgregarMeta();
}

class _EstadoPantallaAgregarMeta extends State<PantallaAgregarMeta> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorMontoObjetivo = TextEditingController();
  final _controladorMontoInicial = TextEditingController(text: '0');

  final ServicioMetas _servicioMetas = ServicioMetas();

  String _monedaSeleccionada = 'HNL';
  DateTime? _fechaLimite; // opcional, puede quedar null
  bool _guardando = false;
  String? _mensajeError;

  final List<String> _monedasDisponibles = ['HNL', 'USD', 'EUR'];

  Future<void> _seleccionarFechaLimite() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() => _fechaLimite = fecha);
    }
  }

  Future<void> _guardarMeta() async {
    if (!_llaveFormulario.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _mensajeError = null;
    });

    try {
      final idUsuario = FirebaseAuth.instance.currentUser!.uid;
      final montoObjetivo = double.parse(_controladorMontoObjetivo.text.trim());
      final montoInicial =
          double.tryParse(_controladorMontoInicial.text.trim()) ?? 0;

      final nuevaMeta = MetaModelo(
        idMeta: '',
        idUsuario: idUsuario,
        nombre: _controladorNombre.text.trim(),
        montoObjetivo: montoObjetivo,
        montoActual: montoInicial,
        moneda: _monedaSeleccionada,
        fechaLimite: _fechaLimite,
        estado: montoInicial >= montoObjetivo ? 'completed' : 'active',
        fechaCreacion: DateTime.now(),
        fechaCompletado: montoInicial >= montoObjetivo ? DateTime.now() : null,
      );

      await _servicioMetas.crearMeta(nuevaMeta);

      if (mounted) Navigator.pop(context);
    } catch (error) {
      setState(() => _mensajeError = 'Error al guardar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorMontoObjetivo.dispose();
    _controladorMontoInicial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva meta de ahorro')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _llaveFormulario,
          child: ListView(
            children: [
              CampoTexto(
                controlador: _controladorNombre,
                etiqueta: 'Nombre de la meta',
                textoAyuda: 'Ej: Refrigeradora nueva',
                validador: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CampoTexto(
                      controlador: _controladorMontoObjetivo,
                      etiqueta: 'Monto objetivo',
                      tipoTeclado: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validador: (valor) {
                        if (valor == null || valor.isEmpty)
                          return 'Ingresa un monto';
                        final numero = double.tryParse(valor);
                        if (numero == null) return 'Monto inválido';
                        if (numero <= 0) return 'Debe ser mayor a 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _monedaSeleccionada,
                      decoration: const InputDecoration(labelText: 'Moneda'),
                      items: _monedasDisponibles
                          .map(
                            (moneda) => DropdownMenuItem(
                              value: moneda,
                              child: Text(moneda),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) =>
                          setState(() => _monedaSeleccionada = valor!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CampoTexto(
                controlador: _controladorMontoInicial,
                etiqueta: 'Monto inicial (opcional)',
                textoAyuda: 'Si ya tienes algo ahorrado',
                tipoTeclado: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validador: (valor) {
                  if (valor == null || valor.isEmpty) return null; // opcional
                  if (double.tryParse(valor) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                  _fechaLimite == null
                      ? 'Sin fecha límite'
                      : '${_fechaLimite!.day}/${_fechaLimite!.month}/${_fechaLimite!.year}',
                ),
                trailing: TextButton(
                  onPressed: _seleccionarFechaLimite,
                  child: const Text('Elegir fecha'),
                ),
              ),
              const SizedBox(height: 20),

              if (_mensajeError != null)
                Text(_mensajeError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),

              BotonPrincipal(
                cargando: _guardando,
                texto: 'Crear meta',
                alPresionar: _guardarMeta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

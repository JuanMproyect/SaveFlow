import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/currency_service.dart';
import '../../services/transaction_service.dart';
import '../../ux/widgets/custom_button.dart';
import '../../ux/widgets/custom_input.dart';

class PantallaAgregarTransaccion extends StatefulWidget {
  const PantallaAgregarTransaccion({super.key});

  @override
  State<PantallaAgregarTransaccion> createState() =>
      _EstadoPantallaAgregarTransaccion();
}

class _EstadoPantallaAgregarTransaccion
    extends State<PantallaAgregarTransaccion> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorMonto = TextEditingController();
  final _controladorDescripcion = TextEditingController();

  final ServicioTransacciones _servicioTransacciones = ServicioTransacciones();
  final ServicioCategorias _servicioCategorias = ServicioCategorias();
  final ServicioMoneda _servicioMoneda = ServicioMoneda();
  final ServicioAutenticacion _servicioAuth = ServicioAutenticacion();

  String _tipoSeleccionado = 'expense';
  String _monedaSeleccionada = 'HNL';
  CategoriaModelo? _categoriaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now();
  bool _guardando = false;
  String? _mensajeError;

  final List<String> _monedasDisponibles = ['HNL', 'USD', 'EUR'];

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _guardarTransaccion() async {
    if (!_llaveFormulario.currentState!.validate()) return;
    if (_categoriaSeleccionada == null) {
      setState(() => _mensajeError = 'Selecciona una categoría');
      return;
    }

    setState(() {
      _guardando = true;
      _mensajeError = null;
    });

    try {
      final idUsuario = FirebaseAuth.instance.currentUser!.uid;
      final usuario = await _servicioAuth.obtenerDatosUsuario(idUsuario);
      final monedaBase = usuario?.monedaBase ?? 'HNL';

      final monto = double.parse(_controladorMonto.text.trim());
      final tipoCambio = await _servicioMoneda.obtenerTipoCambio(
        _monedaSeleccionada,
        monedaBase,
      );
      final montoConvertido = monto * tipoCambio;

      final nuevaTransaccion = TransaccionModelo(
        idTransaccion: '',
        idUsuario: idUsuario,
        idCategoria: _categoriaSeleccionada!.idCategoria,
        tipo: _tipoSeleccionado,
        monto: monto,
        monedaOriginal: _monedaSeleccionada,
        montoConvertido: montoConvertido,
        tipoCambioUsado: tipoCambio,
        descripcion: _controladorDescripcion.text.trim(),
        fecha: _fechaSeleccionada,
        fechaCreacion: DateTime.now(),
      );

      await _servicioTransacciones.guardarTransaccion(nuevaTransaccion);

      if (mounted) Navigator.pop(context);
    } catch (error) {
      setState(() => _mensajeError = 'Error al guardar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final idUsuario = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva transacción')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _llaveFormulario,
          child: ListView(
            children: [
              // Selector de tipo: Gasto / Ingreso
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Gasto'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Ingreso'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_tipoSeleccionado},
                onSelectionChanged: (nuevaSeleccion) {
                  setState(() {
                    _tipoSeleccionado = nuevaSeleccion.first;
                    _categoriaSeleccionada =
                        null; // reinicia categoría al cambiar tipo
                  });
                },
              ),
              const SizedBox(height: 20),

              // Monto y moneda
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CampoTexto(
                      controlador: _controladorMonto,
                      etiqueta: 'Monto',
                      tipoTeclado: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validador: (valor) {
                        if (valor == null || valor.isEmpty)
                          return 'Ingresa un monto';
                        if (double.tryParse(valor) == null)
                          return 'Monto inválido';
                        if (double.parse(valor) <= 0)
                          return 'Debe ser mayor a 0';
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

              // Selector de categoría (filtrado por tipo)
              StreamBuilder<List<CategoriaModelo>>(
                stream: _servicioCategorias.obtenerCategorias(idUsuario),
                builder: (contexto, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categoriasFiltradas = snapshot.data!
                      .where((categoria) => categoria.tipo == _tipoSeleccionado)
                      .toList();

                  return DropdownButtonFormField<CategoriaModelo>(
                    value: categoriasFiltradas.contains(_categoriaSeleccionada)
                        ? _categoriaSeleccionada
                        : null,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categoriasFiltradas
                        .map(
                          (categoria) => DropdownMenuItem(
                            value: categoria,
                            child: Row(
                              children: [
                                Icon(
                                  categoria.obtenerIcono(),
                                  size: 18,
                                  color: categoria.obtenerColor(),
                                ),
                                const SizedBox(width: 8),
                                Text(categoria.nombre),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (valor) =>
                        setState(() => _categoriaSeleccionada = valor),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              CampoTexto(
                controlador: _controladorDescripcion,
                etiqueta: 'Descripción (opcional)',
              ),
              const SizedBox(height: 16),

              // Fecha
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                ),
                trailing: TextButton(
                  onPressed: _seleccionarFecha,
                  child: const Text('Cambiar'),
                ),
              ),
              const SizedBox(height: 20),

              if (_mensajeError != null)
                Text(_mensajeError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),

              BotonPrincipal(
                cargando: _guardando,
                texto: 'Guardar transacción',
                alPresionar: _guardarTransaccion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

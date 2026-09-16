import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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

    setState(() => _cargando = false);

    if (error != null) {
      setState(() => _mensajeError = error);
    } else if (mounted) {
      // Regresamos a la pantalla raíz (donde vive el StreamBuilder).
      // Él ya detectó la sesión activa y mostrará el Dashboard solo.
      Navigator.popUntil(context, (ruta) => ruta.isFirst);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _llaveFormulario,
          child: ListView(
            children: [
              TextFormField(
                controller: _controladorNombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (valor) =>
                    valor == null || valor.isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorCorreo,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (valor) => valor == null || !valor.contains('@')
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controladorContrasena,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (valor) => valor == null || valor.length < 6
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _monedaSeleccionada,
                decoration: const InputDecoration(labelText: 'Moneda base'),
                items: _monedasDisponibles
                    .map(
                      (moneda) =>
                          DropdownMenuItem(value: moneda, child: Text(moneda)),
                    )
                    .toList(),
                onChanged: (valor) =>
                    setState(() => _monedaSeleccionada = valor!),
              ),
              const SizedBox(height: 24),
              if (_mensajeError != null)
                Text(_mensajeError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _manejarRegistro,
                      child: const Text('Registrarme'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

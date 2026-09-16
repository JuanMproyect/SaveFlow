import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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

        setState(() => _cargando = false);

    if (error != null) {
      setState(() => _mensajeError = error);
    }
    // No navegamos manualmente: el StreamBuilder en main.dart
    // detecta el cambio de sesión y muestra el Dashboard automáticamente.
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _llaveFormulario,
          child: ListView(
            children: [
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
                validator: (valor) => valor == null || valor.isEmpty
                    ? 'Ingresa tu contraseña'
                    : null,
              ),
              const SizedBox(height: 24),
              if (_mensajeError != null)
                Text(_mensajeError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _manejarInicioSesion,
                      child: const Text('Entrar'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  contexto,
                  MaterialPageRoute(
                    builder: (contexto) => const PantallaRegistro(),
                  ),
                ),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

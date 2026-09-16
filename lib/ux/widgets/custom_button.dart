import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  final bool cargando;
  final String texto;
  final VoidCallback? alPresionar;

  const BotonPrincipal({
    super.key,
    required this.cargando,
    required this.texto,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext contexto) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: alPresionar, child: Text(texto)),
    );
  }
}

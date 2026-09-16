import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final String? Function(String?)? validador;
  final bool ocultarTexto;
  final TextInputType? tipoTeclado;
  final String? textoAyuda;

  const CampoTexto({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.validador,
    this.ocultarTexto = false,
    this.tipoTeclado,
    this.textoAyuda,
  });

  @override
  Widget build(BuildContext contexto) {
    return TextFormField(
      controller: controlador,
      decoration: InputDecoration(labelText: etiqueta, hintText: textoAyuda),
      validator: validador,
      obscureText: ocultarTexto,
      keyboardType: tipoTeclado,
    );
  }
}

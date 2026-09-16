class MensajeChatModelo {
  final String texto;
  final bool esUsuario; // true = lo escribió el usuario, false = respuesta del bot
  final DateTime fecha;

  MensajeChatModelo({
    required this.texto,
    required this.esUsuario,
    required this.fecha,
  });
}
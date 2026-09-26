class MensajeChatModelo {
  final String idMensaje;
  final String idUsuario;
  final String texto;
  final bool esUsuario;
  final DateTime fecha;

  MensajeChatModelo({
    required this.idMensaje,
    required this.idUsuario,
    required this.texto,
    required this.esUsuario,
    required this.fecha,
  });

  factory MensajeChatModelo.desdeMapa(String id, Map<String, dynamic> datos) {
    return MensajeChatModelo(
      idMensaje: id,
      idUsuario: datos['userId'] ?? '',
      texto: datos['text'] ?? '',
      esUsuario: datos['isUser'] ?? false,
      fecha: datos['date']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'userId': idUsuario,
      'text': texto,
      'isUser': esUsuario,
      'date': fecha,
    };
  }
}
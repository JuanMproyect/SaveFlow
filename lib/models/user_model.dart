class UsuarioModelo {
  final String idUsuario;
  final String correo;
  final String nombreVisible;
  final String monedaBase;
  final DateTime fechaCreacion;
  final DateTime ultimoInicioSesion;

  UsuarioModelo({
    required this.idUsuario,
    required this.correo,
    required this.nombreVisible,
    required this.monedaBase,
    required this.fechaCreacion,
    required this.ultimoInicioSesion,
  });

  // Convierte el objeto UsuarioModelo a un mapa para guardarlo en Firestore
  Map<String, dynamic> aMapa() {
    return {
      'email': correo,
      'displayName': nombreVisible,
      'baseCurrency': monedaBase,
      'createdAt': fechaCreacion,
      'lastLoginAt': ultimoInicioSesion,
    };
  }

  // Crea un UsuarioModelo a partir de un documento leído de Firestore
  factory UsuarioModelo.desdeMapa(String id, Map<String, dynamic> datos) {
    return UsuarioModelo(
      idUsuario: id,
      correo: datos['email'] ?? '',
      nombreVisible: datos['displayName'] ?? '',
      monedaBase: datos['baseCurrency'] ?? 'HNL',
      fechaCreacion: datos['createdAt']?.toDate() ?? DateTime.now(),
      ultimoInicioSesion: datos['lastLoginAt']?.toDate() ?? DateTime.now(),
    );
  }
}
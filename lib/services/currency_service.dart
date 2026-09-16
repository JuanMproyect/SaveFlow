class ServicioMoneda {
  // TODO: Integrar ExchangeRate-API al final del proyecto.
  // Por ahora retorna tasa 1:1, asumiendo que el usuario registra
  // todo en su moneda base sin conversión real.
  Future<double> obtenerTipoCambio(String monedaOrigen, String monedaDestino) async {
    if (monedaOrigen == monedaDestino) return 1.0;

    // Placeholder temporal: sin conexión real a la API todavía.
    return 1.0;
  }

  Future<double> convertir(double monto, String monedaOrigen, String monedaDestino) async {
    final tasa = await obtenerTipoCambio(monedaOrigen, monedaDestino);
    return monto * tasa;
  }
}
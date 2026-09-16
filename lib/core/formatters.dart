import 'package:intl/intl.dart';

// Formatea un monto con comas de miles y 2 decimales.
// Ejemplo: 15000.5 -> "15,000.50"
String formatearMonto(double monto) {
  final formato = NumberFormat('#,##0.00', 'en_US');
  return formato.format(monto);
}
